/*====================================================================================================

TABLE CREATION SCRIPT - SCHEMA [ai]

=====================================================================================================*/
-- SERVER:        ---
-- Database:      DB_TEST
-- TABLE:         ai.aic_AITokenPlanConfig / ai.aih_AIUsageHeader / ai.aiu_AIUsageLog
-- =======================================
-- CREATED by snavarro on 10/03/2026
-- MODIFIED by ---

/*
#Note:
1- Draft for review. The 3 tables in this file all deal with AI usage/quota -> schema [ai].
2- ai.aih_AIUsageHeader is the MONTHLY header per subscription: it is never overwritten or reset to 0 "in place".
   When the period (year/month) changes a NEW row is inserted; the previous period's row stays frozen
   with its final consumption, giving the history the user asked for.
*/

/*====================================================================================================
1. SELECT DATABASE
=====================================================================================================*/

USE DB_TEST

/*====================================================================================================
2. CREATE SCHEMA [ai] IF IT DOES NOT EXIST
=====================================================================================================*/

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'ai')
BEGIN
	EXEC('CREATE SCHEMA [ai]')
END
GO

/*====================================================================================================
3. START OF TRANSACTION
=====================================================================================================*/

BEGIN TRANSACTION


/*====================================================================================================
------------------------------------------------------------------------------------------------------
4- TOKEN CAP CONFIGURATION PER PLAN
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
4.1 CREATE TABLE ai.aic_AITokenPlanConfig
=====================================================================================================*/
/*
Monthly tokens granted by each paid plan (ppp_Id). Administrative view.
*/
IF exists (SELECT name
           FROM sysobjects
           WHERE name='aic_AITokenPlanConfig'
             AND uid=(select schema_id from sys.schemas where name = 'ai')
             AND TYPE='U')
BEGIN
	DROP TABLE [ai].aic_AITokenPlanConfig
END

CREATE TABLE [ai].[aic_AITokenPlanConfig](
	[aic_Id] [uniqueidentifier] NOT NULL, -->Primary key
	[ppp_Id] [uniqueidentifier] NOT NULL, -->FK subscription.ppp_ProductPaymentPlan (the "tier")

	[aic_MonthlyTokenLimit] [bigint] NOT NULL, -->Monthly AI token cap for this plan
	[aic_EffectiveFrom] [DateTime] NOT NULL, -->Date from which this cap applies
	[aic_EffectiveUntil] [DateTime] NULL, -->NULL = valid indefinitely

	[aic_Active] [bit] NOT NULL DEFAULT 1, -->Record status. (0=False; 1=True)
	[aic_CreationDate] [DateTime] NOT NULL, -->Record creation date.
	[aic_CreatedBy] [varchar](50) NULL, -->User who created the record.
	[aic_RemovalDate] [DateTime] NULL, -->Record removal date.
	[aic_RemovedBy] [varchar](50) NULL, -->User who removed the record.
	[aic_Removed] [bit] NOT NULL DEFAULT 0, -->(0=False; 1=True)
 CONSTRAINT [PK_aic_AITokenPlanConfig] PRIMARY KEY CLUSTERED
(
	[aic_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [ai].[aic_AITokenPlanConfig] WITH CHECK ADD CONSTRAINT [FK_aic_Ppp] FOREIGN KEY([ppp_Id])
REFERENCES [subscription].[ppp_ProductPaymentPlan] ([ppp_Id])
GO


/*====================================================================================================
------------------------------------------------------------------------------------------------------
5- MONTHLY AI USAGE HEADER (HISTORY PER PERIOD)
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
5.1 CREATE TABLE ai.aih_AIUsageHeader
=====================================================================================================*/
/*
One row per sus_Id + year + month. When a new period starts a new row is INSERTED (the previous one
is not updated) -> the closed period remains as history, with its final consumption frozen.
*/
IF exists (SELECT name
           FROM sysobjects
           WHERE name='aih_AIUsageHeader'
             AND uid=(select schema_id from sys.schemas where name = 'ai')
             AND TYPE='U')
BEGIN
	DROP TABLE [ai].aih_AIUsageHeader
END

CREATE TABLE [ai].[aih_AIUsageHeader](
	[aih_Id] [uniqueidentifier] NOT NULL, -->Primary key
	[sus_Id] [uniqueidentifier] NOT NULL, -->FK subscription.sus_Subscription
	[ppp_Id] [uniqueidentifier] NULL, -->Snapshot: plan in effect during this period

	[aih_PeriodYear] [smallint] NOT NULL, -->Period year (e.g. 2026)
	[aih_PeriodMonth] [tinyint] NOT NULL, -->Period month (1-12)

	[aih_TokenLimit] [bigint] NOT NULL, -->Snapshot of the cap in effect when this period was created
	[aih_TokensConsumed] [bigint] NOT NULL DEFAULT 0, -->Total consumed in this period
	[aih_RequestCount] [int] NOT NULL DEFAULT 0, -->
	[aih_LimitReachedDate] [DateTime] NULL, -->Set the first time the cap is exhausted

	[aih_Active] [bit] NOT NULL DEFAULT 1, -->Record status. (0=False; 1=True)
	[aih_CreationDate] [DateTime] NOT NULL, -->Record creation date.
	[aih_CreatedBy] [varchar](50) NULL, -->User who created the record.
	[aih_RemovalDate] [DateTime] NULL, -->Record removal date.
	[aih_RemovedBy] [varchar](50) NULL, -->User who removed the record.
	[aih_Removed] [bit] NOT NULL DEFAULT 0, -->(0=False; 1=True)
 CONSTRAINT [PK_aih_AIUsageHeader] PRIMARY KEY CLUSTERED
(
	[aih_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [ai].[aih_AIUsageHeader] WITH CHECK ADD CONSTRAINT [FK_aih_Sus] FOREIGN KEY([sus_Id])
REFERENCES [subscription].[sus_Subscription] ([sus_Id])
GO

ALTER TABLE [ai].[aih_AIUsageHeader] WITH CHECK ADD CONSTRAINT [FK_aih_Ppp] FOREIGN KEY([ppp_Id])
REFERENCES [subscription].[ppp_ProductPaymentPlan] ([ppp_Id])
GO

ALTER TABLE [ai].[aih_AIUsageHeader] ADD CONSTRAINT [UQ_aih_SusPeriod] UNIQUE ([sus_Id],[aih_PeriodYear],[aih_PeriodMonth])
GO


/*====================================================================================================
------------------------------------------------------------------------------------------------------
6- DETAIL OF EACH AI CALL (LOG)
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
6.1 CREATE TABLE ai.aiu_AIUsageLog
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='aiu_AIUsageLog'
             AND uid=(select schema_id from sys.schemas where name = 'ai')
             AND TYPE='U')
BEGIN
	DROP TABLE [ai].aiu_AIUsageLog
END

CREATE TABLE [ai].[aiu_AIUsageLog](
	[aiu_Id] [uniqueidentifier] NOT NULL, -->Primary key
	[aih_Id] [uniqueidentifier] NOT NULL, -->FK ai.aih_AIUsageHeader (period this call belongs to)
	[sus_Id] [uniqueidentifier] NOT NULL, -->FK subscription.sus_Subscription (denormalized for direct queries)

	[aiu_SourceCode] [varchar](20) NOT NULL, -->
	[aiu_PostId] [uniqueidentifier] NULL, -->Related post, if it already exists at call time
	[aiu_Endpoint] [varchar](100) NOT NULL, -->'/api/posts/improve' or '/api/posts/recruitment/improve'

	[aiu_PromptTokens] [int] NOT NULL DEFAULT 0,
	[aiu_CompletionTokens] [int] NOT NULL DEFAULT 0,
	[aiu_TotalTokens] [int] NOT NULL DEFAULT 0,
	[aiu_Model] [varchar](50) NULL,
	[aiu_LatencyMs] [int] NULL,

	[aiu_HttpStatus] [int] NOT NULL, -->200/400/401/429/502/503/504/500
	[aiu_Success] [bit] NOT NULL DEFAULT 1,
	[aiu_ErrorCode] [varchar](50) NULL, -->Only when aiu_Success=0

	[aiu_Active] [bit] NOT NULL DEFAULT 1, -->Record status. (0=False; 1=True)
	[aiu_CreationDate] [DateTime] NOT NULL, -->Record creation date.
	[aiu_CreatedBy] [varchar](50) NULL, -->User who created the record.
	[aiu_RemovalDate] [DateTime] NULL, -->Record removal date.
	[aiu_RemovedBy] [varchar](50) NULL, -->User who removed the record.
	[aiu_Removed] [bit] NOT NULL DEFAULT 0, -->(0=False; 1=True)
 CONSTRAINT [PK_aiu_AIUsageLog] PRIMARY KEY CLUSTERED
(
	[aiu_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [ai].[aiu_AIUsageLog] WITH CHECK ADD CONSTRAINT [FK_aiu_Aih] FOREIGN KEY([aih_Id])
REFERENCES [ai].[aih_AIUsageHeader] ([aih_Id])
GO

ALTER TABLE [ai].[aiu_AIUsageLog] WITH CHECK ADD CONSTRAINT [FK_aiu_Sus] FOREIGN KEY([sus_Id])
REFERENCES [subscription].[sus_Subscription] ([sus_Id])
GO


/*====================================================================================================
7. END OF TRANSACTION
=====================================================================================================*/
-- ROLLBACK /*if the data sample after the change does not match the expected results. */
-- COMMIT   /*when the data sample after the change matches the expected results. */
