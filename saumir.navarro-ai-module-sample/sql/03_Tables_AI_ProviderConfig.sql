/*====================================================================================================

ADJUSTMENT SCRIPT - AI PROVIDER PER PLAN (schema [ai])

=====================================================================================================*/
-- SERVER:        ---
-- Database:      DB_TEST
-- TABLE:         ai.aip_AIProvider (new) + ALTER ai.aic_AITokenPlanConfig
-- =======================================
-- CREATED by snavarro on 10/03/2026
-- MODIFIED by ---

USE DB_TEST
GO

/*====================================================================================================
1- TABLE ai.aip_AIProvider (catalog)
=====================================================================================================*/

BEGIN TRANSACTION

IF exists (SELECT name
           FROM sysobjects
           WHERE name='aip_AIProvider'
             AND uid=(select schema_id from sys.schemas where name = 'ai')
             AND TYPE='U')
BEGIN
	DROP TABLE [ai].aip_AIProvider
END

CREATE TABLE [ai].[aip_AIProvider](
	[aip_Id] [uniqueidentifier] NOT NULL, -->Primary key

	[aip_Code] [varchar](20) NOT NULL, -->'GEMINI','OPENAI','CLAUDE'
	[aip_Name] [varchar](100) NOT NULL,
	[aip_Description] [varchar](255) NULL,

	[aip_Active] [bit] NOT NULL DEFAULT 1, -->Record status. (0=False; 1=True)
	[aip_CreationDate] [DateTime] NOT NULL, -->Record creation date.
	[aip_CreatedBy] [varchar](50) NULL, -->User who created the record.
	[aip_RemovalDate] [DateTime] NULL, -->Record removal date.
	[aip_RemovedBy] [varchar](50) NULL, -->User who removed the record.
	[aip_Removed] [bit] NOT NULL DEFAULT 0, -->(0=False; 1=True)
 CONSTRAINT [PK_aip_AIProvider] PRIMARY KEY CLUSTERED
(
	[aip_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [ai].[aip_AIProvider] ADD CONSTRAINT [UQ_aip_Code] UNIQUE ([aip_Code])
GO


/*====================================================================================================
2- ALTER ai.aic_AITokenPlanConfig - add primary provider + fallback
=====================================================================================================*/

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('[ai].[aic_AITokenPlanConfig]') AND name = 'aip_Id')
BEGIN
	ALTER TABLE [ai].[aic_AITokenPlanConfig] ADD [aip_Id] [uniqueidentifier] NULL -->FK ai.aip_AIProvider (primary provider for this plan)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('[ai].[aic_AITokenPlanConfig]') AND name = 'aip_FallbackId')
BEGIN
	ALTER TABLE [ai].[aic_AITokenPlanConfig] ADD [aip_FallbackId] [uniqueidentifier] NULL -->FK ai.aip_AIProvider (alternate provider, NULL if not applicable)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_aic_Aip')
BEGIN
	ALTER TABLE [ai].[aic_AITokenPlanConfig] WITH CHECK ADD CONSTRAINT [FK_aic_Aip] FOREIGN KEY([aip_Id])
	REFERENCES [ai].[aip_AIProvider] ([aip_Id])
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_aic_AipFallback')
BEGIN
	ALTER TABLE [ai].[aic_AITokenPlanConfig] WITH CHECK ADD CONSTRAINT [FK_aic_AipFallback] FOREIGN KEY([aip_FallbackId])
	REFERENCES [ai].[aip_AIProvider] ([aip_Id])
END
GO

-- COMMIT
-- ROLLBACK
