/*====================================================================================================

SCRIPT CREACIÓN TABLAS (CSALUD)

=====================================================================================================*/
-- SERVER:        ---
-- Database:      CSALUD
-- TABLE:         Gestión de Honorarios
-- ===========================================
-- CREATED by Saumir Navarro, on 02/06/2021
-- MODIFIED by ---

 
/*====================================================================================================
1. SELECCIONA BASE DE DATOS
=====================================================================================================*/

USE  [CS]

/*====================================================================================================
2. INICIO DE LA TRANSACCION
=====================================================================================================*/

BEGIN TRANSACTION


/*====================================================================================================
------------------------------------------------------------------------------------------------------
3- GESTION DE HONORARIOS
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
3.1 CREAR TABLA hon_Honorario
=====================================================================================================*/

select * from [honorario].hon_Honorario

IF exists (SELECT name
           FROM sysobjects
           WHERE name='hon_Honorario'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].hon_Honorario
END

CREATE TABLE [honorario].[hon_Honorario](
	[hon_Id] [uniqueidentifier] NOT NULL, -->Clave Primaria
	[uni_Id] [uniqueidentifier] NOT NULL, -->Unidad de Servicio
	[sed_Id] [uniqueidentifier] NOT NULL, -->Sede/Unidad de Servicio
	[vin_Id] [uniqueidentifier] NOT NULL, -->Vinculo Profesional
	[cbc_Id] [uniqueidentifier] NOT NULL, -->Cuenta Bancaria
			
	[hon_Month] int NOT NULL,
	[hon_Year] [int] NOT NULL,
	[hon_Version] int NOT NULL,

	[hon_MontoVenta] [money] NOT NULL,
	[hon_TotalDescuento] [money] NOT NULL,
	[hon_SubTotalVenta] [money] NOT NULL,

	[hon_PorcConvenio] [money] NOT NULL,
	[hon_TotalConvenio] [money] NOT NULL,

	[hon_MontoDescuento1] [money] NOT NULL,-->Monto de descuento 1 del detalle
	[hon_MontoDescuento2] [money] NOT NULL,-->Monto de descuento 2 del detalle
	
	[hon_MontoDescuentoOtros] [money] NOT NULL,-->Monto de descuento por otros motivos
	[hon_ConceptoDescuentoOtros] [varchar](255) NULL,

	[hon_SubTotalConvenio] [money] NOT NULL,
	
	[hon_PorcImpuesto1] [money] NOT NULL, 
	[hon_MontoImpuesto1] [money] NOT NULL,
	[hon_ConceptoImpuesto1] [varchar](100) NULL,

	[hon_PorcImpuesto2] [money] NOT NULL, 
	[hon_MontoImpuesto2] [money] NOT NULL,
	[hon_ConceptoImpuesto2] [varchar](100) NULL,

	[hon_PorcImpuesto3] [money] NOT NULL, 
	[hon_MontoImpuesto3] [money] NOT NULL,
	[hon_ConceptoImpuesto3] [varchar](100) NULL,	
	
	[hon_MontoTotal] [money] NOT NULL,

	[hon_AceptoPolitica] [bit] NOT NULL, -->0=No;1=Si
	[hon_FechaAceptoPolitica] [datetime] NULL,

	[hon_NotificaUni] [bit] NULL, -->0=No;1=Si
	[hon_FechaNotificaUni] [datetime] NULL,
	[hon_MsgNotificaUni] [datetime] NULL,
		
	[hon_FechaCreacion] [datetime] NOT NULL,
	[hon_UsuarioCreacion] [varchar](50) NOT NULL,
	[hon_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[hon_FechaEliminacion] [datetime] NULL,
	[hon_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_hon_Honorario] PRIMARY KEY CLUSTERED 
(
	[hon_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

/*====================================================================================================
3.2 CREAR TABLA hod_HonorarioDetalle (SE DEBE ELIMINAR TODO LO Q HACE REFERENCIA)
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='hod_HonorarioDetalle'
             --AND uid=(select schema_id from sys.schemas where name = 'factura')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].hod_HonorarioDetalle
END

GO

CREATE TABLE [honorario].[hod_HonorarioDetalle](
	[hod_Id] [uniqueidentifier] NOT NULL, -->Clave Primaria
	[hon_Id] [uniqueidentifier] NOT NULL, -->Honorario
	[fad_Id] [uniqueidentifier] NULL, --Factura Detalle
	[fpa_Id] [uniqueidentifier] NULL, --Forma de Pago
	[ser_Id] [uniqueidentifier] NULL, --Servicio Adicional de Pago.
	[cvo_Id] [uniqueidentifier] NULL, --Convenio Pago.    
	
	[hod_SubtotalVenta] [money] NOT NULL, --Es el precio del servicio full
	[hod_PorcDescuentoAVoluntad] [money] NOT NULL, -->Porcentaje de descuento a voluntad del profesional en la venta
	[hod_MontoDescuentoAVoluntad] [money] NOT NULL,-->Monto de descuento
	[hod_ConceptoDescuentoAVoluntad] [varchar](255) NULL,
	[hod_ResponsableDescuento] [varchar](3) NULL,	
	
	[hod_TotalVenta] [money] NOT NULL, --Es el cobro que se le hizo al paciente y este tuvo que pagar.

	[hod_PorcConvenio] [money] NOT NULL, -->Porcentaje de convenio
	[hod_MontoConvenio] [money] NOT NULL,-->Monto de convenio

	[hod_PorcDescuento1] [money] NOT NULL, -->Porcentaje de descuento
	[hod_MontoDescuento1] [money] NOT NULL,-->Monto de descuento
	[hod_ConceptoDescuento1] [varchar](255) NULL,

	[hod_PorcDescuento2] [money] NOT NULL, -->Porcentaje de descuento
	[hod_MontoDescuento2] [money] NOT NULL,-->Monto de descuento
	[hod_ConceptoDescuento2] [varchar](255) NULL,

	[hod_Total] [money] NOT NULL,-->Total Honorario a Pagar por este servicio

	[hod_Descripcion] [varchar](255) NULL, -->Usado para cuando se agregue un servicio adicional para pago.	
	[hod_FechaCreacion] [datetime] NOT NULL,
	[hod_UsuarioCreacion] [varchar](50) NOT NULL,
	[hod_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[hod_FechaEliminacion] [datetime] NULL,
	[hod_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_hon_HonorarioDetalle] PRIMARY KEY CLUSTERED 
(
	[hod_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

select * from [honorario].[hon_Honorario]
select * from [honorario].[hod_HonorarioDetalle]


/*====================================================================================================
3.3 CREAR TABLA hop_HonorarioProfesional
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='hop_HonorarioProfesional'
             --AND uid=(select schema_id from sys.schemas where name = 'factura')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].hop_HonorarioProfesional
END

GO

CREATE TABLE [honorario].[hop_HonorarioProfesional](
	[hop_Id] [uniqueidentifier] NOT NULL, -->Clave Primaria
	[uni_Id] [uniqueidentifier] NOT NULL, -->Unidad de Servicio
	[sed_Id] [uniqueidentifier] NOT NULL, -->Sede/Unidad de Servicio
	[vin_Id] [uniqueidentifier] NOT NULL, -->Vinculo Profesional
	[fad_Id] [uniqueidentifier] NOT NULL, --Factura Detalle
	[fpa_Id] [uniqueidentifier] NOT NULL, --Forma de Pago
	[ser_Id] [uniqueidentifier] NOT NULL, --Servicio Adicional de Pago.
	[cvo_Id] [uniqueidentifier] NOT NULL, --Convenio Pago. 
	[hon_Id] [uniqueidentifier] NULL, -->Honorarios (es la cabecera): es NULL xq cuando el profesional cierra el Período y solicita pago, es cuando se guadra aqui la info. La unidad clinica debe revisar, ajustar, y solicitar boleta.

	[hop_Month] int NOT NULL,
	[hop_Year] [int] NOT NULL,
	[hop_Version] int NOT NULL,
	
	[hop_SubtotalVenta] [money] NOT NULL, --Es el precio del servicio full
	[hop_PorcDescuentoAVoluntad] [money] NOT NULL, -->Porcentaje de descuento a voluntad del profesional en la venta
	[hop_MontoDescuentoAVoluntad] [money] NOT NULL,-->Monto de descuento
	[hop_ConceptoDescuentoAVoluntad] [varchar](255) NULL,
	[hop_ResponsableDescuento] [varchar](3) NULL,	
	[hop_TotalVenta] [money] NOT NULL, --Es el cobro que se le hizo al paciente y este tuvo que pagar.
	[hop_PorcConvenio] [money] NOT NULL, -->Porcentaje de convenio
	[hop_MontoConvenio] [money] NOT NULL,-->Monto de convenio
	[hop_PorcDescuento1] [money] NOT NULL, -->Porcentaje de descuento
	[hop_MontoDescuento1] [money] NOT NULL,-->Monto de descuento
	[hop_ConceptoDescuento1] [varchar](255) NULL,
	[hop_PorcDescuento2] [money] NOT NULL, -->Porcentaje de descuento
	[hop_MontoDescuento2] [money] NOT NULL,-->Monto de descuento
	[hop_ConceptoDescuento2] [varchar](255) NULL,
	[hop_Total] [money] NOT NULL,-->Total Honorario a Pagar por este servicio
	[hop_Descripcion] [varchar](255) NULL, -->Usado para cuando se agregue un servicio adicional para pago.	
	
	[hop_FechaCreacion] [datetime] NOT NULL,
	[hop_UsuarioCreacion] [varchar](50) NOT NULL,
	[hop_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[hop_FechaEliminacion] [datetime] NULL,
	[hop_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_hop_HonorarioProfesional] PRIMARY KEY CLUSTERED 
(
	[hop_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

/*====================================================================================================
3.4 CREAR TABLA hpc_HonorarioProfesionalReclamo
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='hpc_HonorarioProfesionalReclamo'
             --AND uid=(select schema_id from sys.schemas where name = 'factura')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].hpc_HonorarioProfesionalReclamo
END

GO

CREATE TABLE [honorario].[hpc_HonorarioProfesionalReclamo](
	[hpc_Id] [uniqueidentifier] NOT NULL, -->Clave Primaria
	[uni_Id] [uniqueidentifier] NOT NULL, -->Unidad de Servicio
	[sed_Id] [uniqueidentifier] NOT NULL, -->Sede/Unidad de Servicio
	[vin_Id] [uniqueidentifier] NOT NULL, -->Vinculo Profesional
	[fad_Id] [uniqueidentifier] NOT NULL, --Factura Detalle
	[fpa_Id] [uniqueidentifier] NOT NULL, --Forma de Pago
	[ser_Id] [uniqueidentifier] NOT NULL, --Servicio Adicional de Pago.
	[cvo_Id] [uniqueidentifier] NOT NULL, --Convenio Pago.    

	[hpc_Month] int NOT NULL,
	[hpc_Year] [int] NOT NULL,
	
	[hpc_Descripcion] [varchar](999) NULL,
	
	[hpc_FechaCreacion] [datetime] NOT NULL,
	[hpc_UsuarioCreacion] [varchar](50) NOT NULL,
	[hpc_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[hpc_FechaEliminacion] [datetime] NULL,
	[hpc_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_hpc_HonorarioProfesionalReclamo] PRIMARY KEY CLUSTERED 
(
	[hpc_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO


/*====================================================================================================
------------------------------------------------------------------------------------------------------
4- WORKFLOW DE HONORARIOS
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
4.1 CREAR TABLA wfe_WorkflowEstatus (SE DEBE ELIMINAR TODO LO Q HACE REFERENCIA)
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='wfe_WorkflowEstatus'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].wfe_WorkflowEstatus
END

CREATE TABLE [honorario].[wfe_WorkflowEstatus](
	[wfe_Id] [int] NOT NULL, -->Clave Primaria
	[pai_Id] [uniqueidentifier] NOT NULL, -->Pais
	
	[wfe_Descripcion] [varchar](100) NOT NULL,
	[wfe_DescripcionAccion] [varchar](100) NOT NULL,
	[wfe_Inicia] [bit] NOT NULL DEFAULT 0,
	[wfe_Finaliza] [bit] NOT NULL DEFAULT 0,
	[wfe_RequiereComentario] [bit] NOT NULL DEFAULT 0,
	[wfe_RequiereArchivo] [bit] NOT NULL DEFAULT 0,
		
	[wfe_FechaCreacion] [datetime] NOT NULL,
	[wfe_UsuarioCreacion] [varchar](50) NOT NULL,
	[wfe_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[wfe_FechaEliminacion] [datetime] NULL,
	[wfe_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_wfe_WorkflowEstatus] PRIMARY KEY CLUSTERED 
(
	[wfe_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO


/*====================================================================================================
4.2 CREAR TABLA wfh_WorkflowHonorario (SE DEBE ELIMINAR TODO LO Q HACE REFERENCIA)
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='wfh_WorkflowHonorario'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].wfh_WorkflowHonorario
END

CREATE TABLE [honorario].[wfh_WorkflowHonorario](
	[wfh_Id] [int] NOT NULL, -->Clave Primaria
	[wfe_Id] [int] NOT NULL, -->Workflow Estatus (Crear una tabla con posibles comentarios por wfe para agilizar el comentario)

	[wfh_Responsable] [varchar](3) NOT NULL, -->UNI-VIN
	[wfh_Orden] [int] NOT NULL,
		
	[wfh_FechaCreacion] [datetime] NOT NULL,
	[wfh_UsuarioCreacion] [varchar](50) NOT NULL,
	[wfh_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[wfh_FechaEliminacion] [datetime] NULL,
	[wfh_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_wfh_WorkflowHonorario] PRIMARY KEY CLUSTERED 
(
	[wfh_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

INSERT INTO [honorario].wfh_WorkflowHonorario
SELECT 1, 1, 'UNI', 1, GETDATE(), 'csadmin', 0, NULL, NULL
UNION
SELECT 2, 2, 'VIN', 2, GETDATE(), 'csadmin', 0, NULL, NULL
UNION
SELECT 3, 3, 'VIN', 3, GETDATE(), 'csadmin', 0, NULL, NULL
UNION
SELECT 4, 4, 'UNI', 4, GETDATE(), 'csadmin', 0, NULL, NULL
UNION
SELECT 5, 5, 'UNI', 5, GETDATE(), 'csadmin', 0, NULL, NULL
UNION
SELECT 6, 6, 'VIN', 6, GETDATE(), 'csadmin', 0, NULL, NULL
UNION
SELECT 7, 7, 'UNI', 7, GETDATE(), 'csadmin', 0, NULL, NULL

SELECT * FROM [honorario].wfh_WorkflowHonorario


/*====================================================================================================
4.3 CREAR TABLA wfa_WorkflowHonorarioAccion (SE DEBE ELIMINAR TODO LO Q HACE REFERENCIA)
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='wfa_WorkflowHonorarioAccion'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].wfa_WorkflowHonorarioAccion
END

CREATE TABLE [honorario].[wfa_WorkflowHonorarioAccion](
	[wfa_Id] [int] NOT NULL, -->Clave Primaria
	[wfh_Id] [int] NOT NULL, -->Work flow Honorario
	[wfe_Id] [int] NOT NULL, -->Workflow Estatus

	[wfa_Alias] [varchar](10) NOT NULL,
	[wfa_Orden] [int] NOT NULL,
		
	[wfa_FechaCreacion] [datetime] NOT NULL,
	[wfa_UsuarioCreacion] [varchar](50) NOT NULL,
	[wfa_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[wfa_FechaEliminacion] [datetime] NULL,
	[wfa_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_wfh_WorkflowHonorarioAccion] PRIMARY KEY CLUSTERED 
(
	[wfa_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

INSERT INTO [honorario].wfa_WorkflowHonorarioAccion
SELECT 1, 1, 2, '>>', 1, GETDATE(), 'csadmin', 0, NULL, NULL
--
UNION
SELECT 2, 2, 3, '>>', 1, GETDATE(), 'csadmin', 0, NULL, NULL
UNION
SELECT 3, 2, 1, '<<', 2, GETDATE(), 'csadmin', 0, NULL, NULL
--
UNION
SELECT 4, 3, 4, '>>', 1, GETDATE(), 'csadmin', 0, NULL, NULL
--
UNION
SELECT 5, 4, 5, '>>', 1, GETDATE(), 'csadmin', 0, NULL, NULL
UNION
SELECT 6, 4, 3, '<<', 2, GETDATE(), 'csadmin', 0, NULL, NULL
--
UNION
SELECT 7, 5, 6, '>>', 1, GETDATE(), 'csadmin', 0, NULL, NULL
--
UNION
SELECT 9, 6, 7, '>>', 1, GETDATE(), 'csadmin', 0, NULL, NULL
UNION
SELECT 10, 6, 5, '<<', 2, GETDATE(), 'csadmin', 0, NULL, NULL

select * from [honorario].wfa_WorkflowHonorarioAccion

/*====================================================================================================
4.4 CREAR TABLA wfg_WorkflowGestion (SE DEBE ELIMINAR TODO LO Q HACE REFERENCIA)
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='wfg_WorkflowGestion'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].wfg_WorkflowGestion
END

CREATE TABLE [honorario].[wfg_WorkflowGestion](
	[wfg_Id] [uniqueidentifier] NOT NULL, -->Clave Primaria	
	[uni_Id] [uniqueidentifier] NOT NULL, -->Unidad de Servicio
	[vin_Id] [uniqueidentifier] NOT NULL, -->Vinculo Profesional			
	[hon_Month] [int] NOT NULL,
	[hon_Year] [int] NOT NULL,
	[wfp_Id] [uniqueidentifier] NULL, -->Workflow Pago (es para saber cual es la ultima gestion realizada.
			
	[wfg_FechaCreacion] [datetime] NOT NULL,
	[wfg_UsuarioCreacion] [varchar](50) NOT NULL,
	[wfg_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[wfg_FechaEliminacion] [datetime] NULL,
	[wfg_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_wfg_WorkflowGestion] PRIMARY KEY CLUSTERED 
(
	[wfg_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

/*====================================================================================================
4.5 CREAR TABLA wgd_WorkflowGestionDetalle (SE DEBE ELIMINAR TODO LO Q HACE REFERENCIA)
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='wgd_WorkflowGestionDetalle'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].wgd_WorkflowGestionDetalle
END

CREATE TABLE [honorario].[wgd_WorkflowGestionDetalle](
	[wgd_Id] [uniqueidentifier] NOT NULL, -->Clave Primaria
	[wfg_Id] [uniqueidentifier] NOT NULL, -->Workflow Gestion
	[hor_Id] [uniqueidentifier] NOT NULL, -->Honorario
				
	[wgd_FechaCreacion] [datetime] NOT NULL,
	[wgd_UsuarioCreacion] [varchar](50) NOT NULL,
	[wgd_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[wgd_FechaEliminacion] [datetime] NULL,
	[wgd_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_wgd_WorkflowGestionDetalle] PRIMARY KEY CLUSTERED 
(
	[wgd_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

/*====================================================================================================
4.6 CREAR TABLA wfp_WorkflowPago (SE DEBE ELIMINAR TODO LO Q HACE REFERENCIA)
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='wfp_WorkflowPago'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].wfp_WorkflowPago
END

CREATE TABLE [honorario].[wfp_WorkflowPago](
	[wfp_Id] [uniqueidentifier] NOT NULL, -->Clave Primaria	
	[wfg_Id] [uniqueidentifier] NOT NULL, -->Workflow Gestion	
	[wfh_Id] [int] NOT NULL, -->Work flow Honorario	
	[uni_Id] [uniqueidentifier] NULL, -->Unidad de Servicio
	[vin_Id] [uniqueidentifier] NULL, -->Vinculo Profesional

	[wfp_Comentario] [varchar](255) NULL,
	[wfp_ImagenName] [varchar](50) NULL,
    [wfp_ImagenContentType] [varchar](200) NULL,
	[wfp_Imagen] [varbinary](max) NULL,	

	[wfp_Realizado] [bit] NOT NULL, -->0=No;1=Si
			
	[wfp_FechaCreacion] [datetime] NOT NULL,
	[wfp_UsuarioCreacion] [varchar](50) NOT NULL,
	[wfp_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[wfp_FechaEliminacion] [datetime] NULL,
	[wfp_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_wfp_WorkflowPago] PRIMARY KEY CLUSTERED 
(
	[wfp_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

/*====================================================================================================
------------------------------------------------------------------------------------------------------
5- PAGO DE HONORARIOS
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
5.1 CREAR TABLA phn_PagoHonorario
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='phn_PagoHonorario'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].phn_PagoHonorario
END

CREATE TABLE [honorario].[phn_PagoHonorario](
	[phn_Id] [uniqueidentifier] NOT NULL, -->Clave Primaria
	[uni_Id] [uniqueidentifier] NULL, -->Unidad de Servicio
	[vin_Id] [uniqueidentifier] NOT NULL, -->Workflow Pago
	[cbc_Id] [uniqueidentifier] NOT NULL, -->Cuenta Bancaria

	[phn_Month] [int] NOT NULL,
	[phn_Year] [int] NOT NULL,
	[phn_Version] int NOT NULL,

	[phn_ComentarioUni] [varchar](255) NULL, --Comentario de la Unidad Clinica hacia el Profesional

	[phn_NotificaVin] [bit] NULL, -->0=No;1=Si
	[phn_FechaNotificaVin] [datetime] NULL,
	[phn_MsgNotificaVin] [datetime] NULL,

	[phn_ImagenName] [varchar](50) NULL,
    [phn_ImagenContentType] [varchar](200) NULL,
	[phn_Imagen] [varbinary](max) NULL,

	[phn_NotificaUni] [bit] NULL, -->0=No;1=Si
	[phn_FechaNotificaUni] [datetime] NULL,
	[phn_MsgNotificaUni] [datetime] NULL,

	[phn_MontoPagado] [money] NULL,	
	[phn_DescripcionPago] [varchar](500) NULL,
	[phn_Pagado] [bit] NULL, -->0=No;1=Si

	[phn_NotificaPagoVin] [bit] NULL, -->0=No;1=Si
	[phn_FechaNotificaPagoVin] [datetime] NULL,
	[phn_MsgNotificaPagoVin] [datetime] NULL,
		
	[phn_FechaCreacion] [datetime] NOT NULL,
	[phn_UsuarioCreacion] [varchar](50) NOT NULL,
	[phn_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[phn_FechaEliminacion] [datetime] NULL,
	[phn_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_phn_PagoHonorario] PRIMARY KEY CLUSTERED 
(
	[phn_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

select * from [profesionalmedico].[cbc_CuentaBancaria]
select * from [honorario].[hon_Honorario]
select * from [honorario].hop_HonorarioProfesional
select * from [honorario].[phn_PagoHonorario]
where phn_Id='e12b832f-aeba-425b-9cfe-1f46ea964fb3'
select * from [honorario].phd_PagoHonorarioDetalle

select * from [honorario].[wfp_WorkflowPago]
select * from [honorario].wgd_WorkflowGestionDetalle
select * from [honorario].wfg_WorkflowGestion

select * from [honorario].[hod_HonorarioDetalle]

update [honorario].[hon_Honorario]
set cbc_Id='9F19C825-31E5-41C1-9059-EDA100FB5E66'




/*====================================================================================================
5.2 CREAR TABLA phd_PagoHonorarioDetalle
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='phd_PagoHonorarioDetalle'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='U')
BEGIN
	DROP TABLE [honorario].phd_PagoHonorarioDetalle
END

CREATE TABLE [honorario].[phd_PagoHonorarioDetalle](
	[phd_Id] [uniqueidentifier] NOT NULL, -->Clave Primaria
	[uni_Id] [uniqueidentifier] NULL, -->Unidad de Servicio (Se redunda para una llave de seguridad)
	[hon_Id] [uniqueidentifier] NOT NULL, -->Honorarios
	[phn_Id] [uniqueidentifier] NOT NULL, -->Pago Honorarios
	
	[phn_FechaCreacion] [datetime] NOT NULL,
	[phn_UsuarioCreacion] [varchar](50) NOT NULL,
	[phn_Eliminado] [bit] NOT NULL, -->0=No;1=Si
	[phn_FechaEliminacion] [datetime] NULL,
	[phn_UsuarioEliminacion] [varchar](50) NULL,
 CONSTRAINT [PK_phd_PagoHonorarioDetalle] PRIMARY KEY CLUSTERED 
(
	[phd_Id] ASC
) ON [PRIMARY]
) ON [PRIMARY]

GO

/*====================================================================================================
6. FIN DE LA TRANSACCION
=====================================================================================================*/
-- ROLLBACK /*en caso de que la muestra de datos despues del cambio no coincida con los resultados. */
-- COMMIT   /*cuando la muestra de datos despues del cambio coincide con los resultados. */