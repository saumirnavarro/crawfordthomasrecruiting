/*====================================================================================================

SP SCRIPT - AI PROVIDER LOOKUP PER PLAN (so the AI API no longer decides on its own)

=====================================================================================================*/
-- SERVER:        ---
-- Database:      DB_TEST
-- SP:            ai.ps_Aic_GetProviderForPlan
-- =======================================
-- CREATED by snavarro on 10/03/2026
-- MODIFIED by ---

USE DB_TEST
GO

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[ai].[ps_Aic_GetProviderForPlan]') AND type in (N'P'))
	DROP PROCEDURE [ai].[ps_Aic_GetProviderForPlan]
GO

CREATE PROCEDURE [ai].[ps_Aic_GetProviderForPlan]
	@ppp_Id UNIQUEIDENTIFIER
AS
BEGIN
	SET NOCOUNT ON

	SELECT
		aic.ppp_Id,
		aic.aic_MonthlyTokenLimit                               AS MonthlyTokenLimit,
		primaryProv.aip_Code                                    AS PrimaryProvider,
		primaryProv.aip_Name                                    AS PrimaryProviderName,
		fallbackProv.aip_Code                                    AS FallbackProvider,
		fallbackProv.aip_Name                                    AS FallbackProviderName
	FROM [ai].[aic_AITokenPlanConfig] aic
	INNER JOIN [ai].[aip_AIProvider] primaryProv ON primaryProv.aip_Id = aic.aip_Id AND primaryProv.aip_Removed = 0
	LEFT JOIN [ai].[aip_AIProvider] fallbackProv ON fallbackProv.aip_Id = aic.aip_FallbackId AND fallbackProv.aip_Removed = 0
	WHERE aic.ppp_Id = @ppp_Id
	  AND aic.aic_Active = 1
	  AND aic.aic_Removed = 0
	  AND (aic.aic_EffectiveUntil IS NULL OR aic.aic_EffectiveUntil > GETDATE())
	ORDER BY aic.aic_EffectiveFrom DESC
END
GO
