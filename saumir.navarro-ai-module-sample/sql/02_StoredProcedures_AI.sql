/*====================================================================================================

STORED PROCEDURE CREATION SCRIPT - SCHEMA [ai]

=====================================================================================================*/
-- SERVER:        ---
-- Database:      DB_TEST
-- SP:            ai.pi_Aih_GetOrCreateCurrentHeader / ai.ps_Aih_RemainingQuota / ai.pi_Aiu_LogUsage
-- =======================================
-- CREATED by snavarro on 10/03/2026
-- MODIFIED by ---

USE DB_TEST
GO

/*====================================================================================================
------------------------------------------------------------------------------------------------------
1- ai.pi_Aih_GetOrCreateCurrentHeader
------------------------------------------------------------------------------------------------------
=====================================================================================================*/
/*
Returns (creating it if missing) the header row for the CURRENT period (today's year/month) of a
subscription. Resolves the active plan and the token cap in effect for that plan.
*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ai].[pi_Aih_GetOrCreateCurrentHeader]') AND type in (N'P'))
	DROP PROCEDURE [ai].[pi_Aih_GetOrCreateCurrentHeader]
GO

CREATE PROCEDURE [ai].[pi_Aih_GetOrCreateCurrentHeader]
	@sus_Id UNIQUEIDENTIFIER,
	@CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @_year SMALLINT = YEAR(GETDATE())
	DECLARE @_month TINYINT = MONTH(GETDATE())
	DECLARE @_aihId UNIQUEIDENTIFIER
	DECLARE @_pppId UNIQUEIDENTIFIER
	DECLARE @_tokenLimit BIGINT

	-- Does the header for this period already exist?
	SELECT @_aihId = aih_Id
	FROM [ai].[aih_AIUsageHeader]
	WHERE sus_Id = @sus_Id
	  AND aih_PeriodYear = @_year
	  AND aih_PeriodMonth = @_month
	  AND aih_Removed = 0

	IF @_aihId IS NOT NULL
	BEGIN
		-- Already exists: return it as is
		SELECT aih_Id, sus_Id, ppp_Id, aih_PeriodYear, aih_PeriodMonth,
		       aih_TokenLimit, aih_TokensConsumed, aih_RequestCount, aih_LimitReachedDate
		FROM [ai].[aih_AIUsageHeader]
		WHERE aih_Id = @_aihId
		RETURN
	END

	-- Does not exist: resolve the active plan of this subscription
	-- PROPOSAL: dsu_DetailSubscription (1 per sus_Id) -> active, valid psu_ProductSuscription -> ppp_Id
	SELECT TOP 1 @_pppId = psu.ppp_Id
	FROM [subscription].[dsu_DetailSubscription] dsu
	INNER JOIN [subscription].[psu_ProductSuscription] psu ON psu.dsu_Id = dsu.dsu_Id
	LEFT JOIN [subscription].[psl_ProductSubscriptionLicense] psl ON psl.psu_Id = psu.psu_Id
	                                                              AND psl.psl_Removed = 0
	WHERE dsu.sus_Id = @sus_Id
	  AND dsu.dsu_Removed = 0
	  AND psu.psu_Active = 1
	  AND psu.psu_Removed = 0
	  AND (psl.psl_Id IS NULL
	       OR GETDATE() BETWEEN psl.psl_DateFrom AND DATEADD(DAY, psl.psl_AdditionalDay, psl.psl_DateUntil))
	ORDER BY psu.psu_CreationDate DESC

	-- Cap in effect for that plan
	SELECT TOP 1 @_tokenLimit = aic_MonthlyTokenLimit
	FROM [ai].[aic_AITokenPlanConfig]
	WHERE ppp_Id = @_pppId
	  AND aic_Active = 1
	  AND aic_Removed = 0
	  AND aic_EffectiveFrom <= GETDATE()
	  AND (aic_EffectiveUntil IS NULL OR aic_EffectiveUntil >= GETDATE())
	ORDER BY aic_EffectiveFrom DESC

	-- If no plan was resolved or there is no cap configuration, assume 0 (no quota) instead of NULL
	IF @_tokenLimit IS NULL
		SET @_tokenLimit = 0

	SET @_aihId = NEWID()

	INSERT INTO [ai].[aih_AIUsageHeader]
		(aih_Id, sus_Id, ppp_Id, aih_PeriodYear, aih_PeriodMonth, aih_TokenLimit,
		 aih_TokensConsumed, aih_RequestCount, aih_LimitReachedDate,
		 aih_Active, aih_CreationDate, aih_CreatedBy, aih_RemovalDate, aih_RemovedBy, aih_Removed)
	VALUES
		(@_aihId, @sus_Id, @_pppId, @_year, @_month, @_tokenLimit,
		 0, 0, NULL,
		 1, GETDATE(), @CreatedBy, NULL, NULL, 0)

	SELECT aih_Id, sus_Id, ppp_Id, aih_PeriodYear, aih_PeriodMonth,
	       aih_TokenLimit, aih_TokensConsumed, aih_RequestCount, aih_LimitReachedDate
	FROM [ai].[aih_AIUsageHeader]
	WHERE aih_Id = @_aihId
END
GO


/*====================================================================================================
------------------------------------------------------------------------------------------------------
2- ai.ps_Aih_RemainingQuota
------------------------------------------------------------------------------------------------------
=====================================================================================================*/
/*
Remaining-quota query for the current period. Called by the app BEFORE enabling "Improve with AI",
and by the Settings screen to show usage to the user.
*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ai].[ps_Aih_RemainingQuota]') AND type in (N'P'))
	DROP PROCEDURE [ai].[ps_Aih_RemainingQuota]
GO

CREATE PROCEDURE [ai].[ps_Aih_RemainingQuota]
	@sus_Id UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON

	-- Ensure the current-period header exists (creates it if missing)
	DECLARE @_tmp TABLE (aih_Id UNIQUEIDENTIFIER, sus_Id UNIQUEIDENTIFIER, ppp_Id UNIQUEIDENTIFIER,
	                     aih_PeriodYear SMALLINT, aih_PeriodMonth TINYINT, aih_TokenLimit BIGINT,
	                     aih_TokensConsumed BIGINT, aih_RequestCount INT, aih_LimitReachedDate DATETIME)

	INSERT INTO @_tmp
	EXEC [ai].[pi_Aih_GetOrCreateCurrentHeader] @sus_Id = @sus_Id

	
	SELECT
		aih_Id,
		aih_PeriodYear,
		aih_PeriodMonth,
		aih_TokenLimit                                     AS TokenLimit,
		aih_TokensConsumed                                  AS TokensConsumed,
		CASE WHEN aih_TokenLimit = -1 THEN NULL ELSE (aih_TokenLimit - aih_TokensConsumed) END AS Remaining,
		CASE WHEN aih_TokenLimit = -1 THEN 0
		     WHEN aih_TokensConsumed >= aih_TokenLimit THEN 1
		     ELSE 0 END AS IsExhausted
	FROM @_tmp
END
GO


/*====================================================================================================
------------------------------------------------------------------------------------------------------
3- ai.pi_Aiu_LogUsage
------------------------------------------------------------------------------------------------------
=====================================================================================================*/
/*
Records a Conexta.AI call: inserts the detail row into aiu_AIUsageLog AND adds the consumption to the
current period header, in a single transaction.
*/
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ai].[pi_Aiu_LogUsage]') AND type in (N'P'))
	DROP PROCEDURE [ai].[pi_Aiu_LogUsage]
GO

CREATE PROCEDURE [ai].[pi_Aiu_LogUsage]
	@sus_Id UNIQUEIDENTIFIER,
	@SourceCode VARCHAR(20), -->ptyCode or 'RECRUITMENT'
	@PostId UNIQUEIDENTIFIER = NULL,
	@Endpoint VARCHAR(100),
	@PromptTokens INT = 0,
	@CompletionTokens INT = 0,
	@TotalTokens INT = 0,
	@Model VARCHAR(50) = NULL,
	@LatencyMs INT = NULL,
	@HttpStatus INT,
	@Success BIT = 1,
	@ErrorCode VARCHAR(50) = NULL,
	@CreatedBy VARCHAR(50) = 'system'
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @_tmp TABLE (aih_Id UNIQUEIDENTIFIER, sus_Id UNIQUEIDENTIFIER, ppp_Id UNIQUEIDENTIFIER,
		                     aih_PeriodYear SMALLINT, aih_PeriodMonth TINYINT, aih_TokenLimit BIGINT,
		                     aih_TokensConsumed BIGINT, aih_RequestCount INT, aih_LimitReachedDate DATETIME)

		INSERT INTO @_tmp
		EXEC [ai].[pi_Aih_GetOrCreateCurrentHeader] @sus_Id = @sus_Id, @CreatedBy = @CreatedBy

		DECLARE @_aihId UNIQUEIDENTIFIER = (SELECT TOP 1 aih_Id FROM @_tmp)

		INSERT INTO [ai].[aiu_AIUsageLog]
			(aiu_Id, aih_Id, sus_Id, aiu_SourceCode, aiu_PostId, aiu_Endpoint,
			 aiu_PromptTokens, aiu_CompletionTokens, aiu_TotalTokens, aiu_Model, aiu_LatencyMs,
			 aiu_HttpStatus, aiu_Success, aiu_ErrorCode,
			 aiu_Active, aiu_CreationDate, aiu_CreatedBy, aiu_RemovalDate, aiu_RemovedBy, aiu_Removed)
		VALUES
			(NEWID(), @_aihId, @sus_Id, @SourceCode, @PostId, @Endpoint,
			 @PromptTokens, @CompletionTokens, @TotalTokens, @Model, @LatencyMs,
			 @HttpStatus, @Success, @ErrorCode,
			 1, GETDATE(), @CreatedBy, NULL, NULL, 0)

		-- Only successful AI calls consume quota
		IF @Success = 1
		BEGIN
			
			UPDATE [ai].[aih_AIUsageHeader]
			SET aih_TokensConsumed = aih_TokensConsumed + @TotalTokens,
			    aih_RequestCount = aih_RequestCount + 1,
			    aih_LimitReachedDate = CASE
			        WHEN aih_TokenLimit <> -1
			             AND aih_LimitReachedDate IS NULL
			             AND (aih_TokensConsumed + @TotalTokens) >= aih_TokenLimit
			        THEN GETDATE()
			        ELSE aih_LimitReachedDate
			    END
			WHERE aih_Id = @_aihId
		END

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
		THROW
	END CATCH
END
GO
