/*====================================================================================================

SCRIPT CREACIÓN STORED PROCEDURE (CSALUD)

=====================================================================================================*/
-- SERVER:        ---
-- Database:      CSALUD
-- TABLE:         Historia Médica
-- =======================================
-- CREATED by Saumir Navarro, on 14/06/2017
-- MODIFIED by ---

 
/*====================================================================================================
1. SELECCIONA BASE DE DATOS
=====================================================================================================*/

USE  [DB_CS]	

/*====================================================================================================
2. INICIO DE LA TRANSACCION
=====================================================================================================*/

BEGIN TRANSACTION


/*====================================================================================================
------------------------------------------------------------------------------------------------------
3- Honorarios
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
3.2. CREAR SP ps_Hon_HonorariosTotalesPorUniId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_HonorariosTotalesPorUniId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_HonorariosTotalesPorUniId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_HonorariosTotalesPorUniId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

--  exec [honorario].[ps_Hon_HonorariosTotalesPorUniId] 4, 2021, '863C4678-B9B2-474E-A913-D1526D7CCBBE'

CREATE PROCEDURE [honorario].[ps_Hon_HonorariosTotalesPorUniId]
@hon_Month int
,@hon_Year int
,@uniId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
		SELECT 	
			uni.[uni_NombreLegal]
			,sed.[sed_Nombre]
			,SUM(hon_SubTotalVenta) hon_SubTotalVenta
			,SUM(hon_MontoTotal) hon_MontoTotal
		FROM [honorario].hon_Honorario hon INNER JOIN [unidadservicio].[uni_UnidadServicio] uni
			ON uni.uni_Id=hon.uni_Id INNER JOIN [unidadservicio].[sed_Sede] sed
			ON sed.sed_Id=hon.sed_Id
		WHERE hon.hon_Eliminado=0
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
		GROUP BY uni.[uni_NombreLegal]
			,sed.[sed_Nombre]

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_HonorariosTotalesPorUniId TO PUBLIC

GO

/*====================================================================================================
3.3. CREAR SP ps_Hon_HonorariosRankingPorUniId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_HonorariosRankingPorUniId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_HonorariosRankingPorUniId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_HonorariosRankingPorUniId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

--  exec [honorario].[ps_Hon_HonorariosRankingPorUniId] 4, 2021, '863C4678-B9B2-474E-A913-D1526D7CCBBE'

CREATE PROCEDURE [honorario].[ps_Hon_HonorariosRankingPorUniId]
@hon_Month int
,@hon_Year int
,@uniId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
		
		SELECT * FROM (
		SELECT 	
			dsu.[dsu_Nombre] + ' ' + dsu.dsu_Apellido as fullNamePme
			,SUM(hon_MontoTotal) hon_MontoTotal
		FROM [honorario].hon_Honorario hon INNER JOIN [unidadservicio].[vin_Vinculacion] vin
			ON vin.vin_Id=hon.vin_Id INNER JOIN [profesionalmedico].[pme_ProfesionalMedico] pme
			ON pme.pme_Id=vin.pme_Id INNER JOIN [suscripcion].[dsu_DetalleSuscripcion] dsu
			ON dsu.dsu_Id=pme.dsu_Id
		WHERE hon.hon_Eliminado=0
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
		GROUP BY dsu.[dsu_Nombre] + ' ' + dsu.dsu_Apellido) t1
		ORDER BY t1.hon_MontoTotal DESC

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_HonorariosRankingPorUniId TO PUBLIC

GO

/*====================================================================================================
3.4. CREAR SP ps_Hon_ProfesionalesSinHonorariosPorUniId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_ProfesionalesSinHonorariosPorUniId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_ProfesionalesSinHonorariosPorUniId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_ProfesionalesSinHonorariosPorUniId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

--  exec [honorario].[ps_Hon_ProfesionalesSinHonorariosPorUniId] 4, 2021, '863C4678-B9B2-474E-A913-D1526D7CCBBE'

CREATE PROCEDURE [honorario].[ps_Hon_ProfesionalesSinHonorariosPorUniId]
@hon_Month int
,@hon_Year int
,@uniId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
		
		
		SELECT 	
			dsu.[dsu_Nombre] + ' ' + dsu.dsu_Apellido as fullNamePme			
		FROM [unidadservicio].[vin_Vinculacion] vin INNER JOIN [profesionalmedico].[pme_ProfesionalMedico] pme
			ON pme.pme_Id=vin.pme_Id INNER JOIN [suscripcion].[dsu_DetalleSuscripcion] dsu
			ON dsu.dsu_Id=pme.dsu_Id
		WHERE vin.vin_Eliminado=0
			AND vin.uni_Id=@uniId		
			AND NOT EXISTS (SELECT hon_Id FROM [honorario].hon_Honorario hon 
								WHERE hon.uni_Id=@uniId
									  and hon.hon_Year=@hon_Year
									  and hon.hon_Month=@hon_Month
									  and hon.vin_Id=vin.vin_Id)
		

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_ProfesionalesSinHonorariosPorUniId TO PUBLIC

GO


/*====================================================================================================
3.5. CREAR SP ps_Hon_HonorariosProfesionalesPorUniId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_HonorariosProfesionalesPorUniId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_HonorariosProfesionalesPorUniId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_HonorariosProfesionalesPorUniId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

--  exec [honorario].[ps_Hon_HonorariosProfesionalesPorUniId] 4, 2021, '863C4678-B9B2-474E-A913-D1526D7CCBBE'

CREATE PROCEDURE [honorario].[ps_Hon_HonorariosProfesionalesPorUniId]
@hon_Month int
,@hon_Year int
,@uniId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
		SELECT 	
			hon.vin_Id
			,dsu.[dsu_Nombre] + ' ' + dsu.dsu_Apellido as fullNamePme
			,vin.vin_PorcConvenio
			,'En Proceso de Cálculo' as hon_EstadoProceso
			,Sum(hon_MontoTotal)  hon_MontoTotal
		FROM [honorario].hon_Honorario hon INNER JOIN [unidadservicio].[vin_Vinculacion] vin
			ON vin.vin_Id=hon.vin_Id INNER JOIN [profesionalmedico].[pme_ProfesionalMedico] pme
			ON pme.pme_Id=vin.pme_Id INNER JOIN [suscripcion].[dsu_DetalleSuscripcion] dsu
			ON dsu.dsu_Id=pme.dsu_Id 
		WHERE hon.hon_Eliminado=0
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
		GROUP BY hon.vin_Id
			,dsu.[dsu_Nombre] + ' ' + dsu.dsu_Apellido
			,vin.vin_PorcConvenio

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_HonorariosProfesionalesPorUniId TO PUBLIC

GO

/*====================================================================================================
3.6. CREAR SP ps_Hon_HonorariosProfesionalesDetallePorSedId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_HonorariosProfesionalesDetallePorSedId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_HonorariosProfesionalesDetallePorSedId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_HonorariosProfesionalesDetallePorSedId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[ps_Hon_HonorariosProfesionalesDetallePorSedId]
@hon_Month int
,@hon_Year int
,@uniId uniqueidentifier
,@vinId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
		SELECT 	
			sed.sed_Nombre
			,hon_MontoTotal
		FROM [honorario].hon_Honorario hon INNER JOIN [unidadservicio].[vin_Vinculacion] vin
			ON vin.vin_Id=hon.vin_Id INNER JOIN [profesionalmedico].[pme_ProfesionalMedico] pme
			ON pme.pme_Id=vin.pme_Id INNER JOIN [suscripcion].[dsu_DetalleSuscripcion] dsu
			ON dsu.dsu_Id=pme.dsu_Id INNER JOIN [unidadservicio].[sed_Sede] sed
			ON sed.sed_Id=hon.sed_Id
		WHERE hon.hon_Eliminado=0
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
			and hon.vin_Id=@vinId
		

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_HonorariosProfesionalesDetallePorSedId TO PUBLIC

GO

/*====================================================================================================
3.8. CREAR SP ps_Hon_HonorariosProfesionalesPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_HonorariosProfesionalesPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_HonorariosProfesionalesPorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_HonorariosProfesionalesPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

--  exec [honorario].[ps_Hon_HonorariosProfesionalesPorVinId] 4, 2021, '863C4678-B9B2-474E-A913-D1526D7CCBBE'

CREATE PROCEDURE [honorario].[ps_Hon_HonorariosProfesionalesPorVinId]
@hon_Month int
,@hon_Year int
,@vinId uniqueidentifier
,@uniId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
		SELECT 	
			hon.vin_Id
			,hon.hon_Id
			,dsu.[dsu_Nombre] + ' ' + dsu.dsu_Apellido as fullNamePme
			,vin.vin_PorcConvenio
			,'En Proceso de Cálculo' as hon_EstadoProceso
			,(SELECT COUNT(*) FROM [honorario].[phn_PagoHonorario] phn LEFT JOIN [honorario].phd_PagoHonorarioDetalle phd 
				ON phn.phn_Id=phd.phn_Id 
			  WHERE phd.hon_Id=hon.hon_Id and phd.phn_Eliminado=0 and phn.phn_Eliminado=0) as phn_PorAdjuntarBoleta

			  ,(SELECT COUNT(*) FROM [honorario].[phn_PagoHonorario] phn LEFT JOIN [honorario].phd_PagoHonorarioDetalle phd 
				ON phn.phn_Id=phd.phn_Id 
			  WHERE phd.hon_Id=hon.hon_Id and phd.phn_Eliminado=0 and phn.phn_Eliminado=0 and phn.phn_ImagenName  IS NOT NULL) as phn_PorPagado

			 ,(SELECT COUNT(*) FROM [honorario].[phn_PagoHonorario] phn LEFT JOIN [honorario].phd_PagoHonorarioDetalle phd 
				ON phn.phn_Id=phd.phn_Id 
			  WHERE phd.hon_Id=hon.hon_Id and phd.phn_Eliminado=0 and phn.phn_Eliminado=0 and phn.phn_Pagado=1) as phn_Pagado
			,SUM(hon_MontoTotal)  hon_MontoTotal
			,MAX(phn.phn_Id) phn_Id
			,MAX(hon_Version) hon_Version
		FROM [honorario].hon_Honorario hon LEFT JOIN [unidadservicio].[vin_Vinculacion] vin
			ON vin.vin_Id=hon.vin_Id LEFT JOIN [profesionalmedico].[pme_ProfesionalMedico] pme
			ON pme.pme_Id=vin.pme_Id LEFT JOIN [suscripcion].[dsu_DetalleSuscripcion] dsu
			ON dsu.dsu_Id=pme.dsu_Id LEFT JOIN [honorario].phd_PagoHonorarioDetalle phd
			ON phd.hon_Id=hon.hon_Id LEFT JOIN [honorario].[phn_PagoHonorario] phn
			ON phn.phn_Id=phd.phn_Id
		WHERE isnull(hon.hon_Eliminado,0)=0
			--and isnull(phn.phn_Eliminado,0)=0
			--and ISNULL(phd.phn_Eliminado,0)=0
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
			and hon.vin_Id=@vinId
		GROUP BY hon.vin_Id
			,hon.hon_Id
			,dsu.[dsu_Nombre] + ' ' + dsu.dsu_Apellido
			,vin.vin_PorcConvenio
		order by 5, 6, 7, 11 desc

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_HonorariosProfesionalesPorVinId TO PUBLIC

GO

/*====================================================================================================
3.11. CREAR SP ps_Hon_HonorariosProfesionalesPeriodoActualPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_HonorariosProfesionalesPeriodoActualPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_HonorariosProfesionalesPeriodoActualPorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_HonorariosProfesionalesPeriodoActualPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

--  exec [honorario].[ps_Hon_HonorariosProfesionalesPeriodoActualPorVinId] '047F81BA-31D7-4F22-808A-7B5E3A2C83C3'

CREATE PROCEDURE [honorario].[ps_Hon_HonorariosProfesionalesPeriodoActualPorVinId]
@vinId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON

		DECLARE @_fechaActual DATETIME
		SET @_fechaActual=GETDATE();

			
		SELECT 	
			hon.vin_Id
			,hon.uni_Id
			,uni.uni_NombreLegal
			,hon.hon_Id
			,dsu.[dsu_Nombre] + ' ' + dsu.dsu_Apellido as fullNamePme
			,vin.vin_PorcConvenio
			,hon_Month
			,hon_Year
			,Sum(hon_MontoTotal)  hon_MontoTotal
		FROM [honorario].hon_Honorario hon INNER JOIN [unidadservicio].[vin_Vinculacion] vin
			ON vin.vin_Id=hon.vin_Id INNER JOIN [profesionalmedico].[pme_ProfesionalMedico] pme
			ON pme.pme_Id=vin.pme_Id INNER JOIN [suscripcion].[dsu_DetalleSuscripcion] dsu
			ON dsu.dsu_Id=pme.dsu_Id INNER JOIN [unidadservicio].uni_UnidadServicio uni
			ON uni.uni_Id=hon.uni_Id
		WHERE hon.hon_Eliminado=0
			and hon.hon_Year=YEAR(@_fechaActual)
			and hon.hon_Month=MONTH(@_fechaActual)
			and hon.vin_Id =@vinId
		GROUP BY hon.vin_Id
			,hon.uni_Id
			,uni.uni_NombreLegal
			,hon.hon_Id
			,dsu.[dsu_Nombre] + ' ' + dsu.dsu_Apellido
			,vin.vin_PorcConvenio
			,hon_Month
			,hon_Year

		

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_HonorariosProfesionalesPeriodoActualPorVinId TO PUBLIC

GO

/*====================================================================================================
------------------------------------------------------------------------------------------------------
3- CERRAR PERIODO DE HONORARIOS Y SOLICITAR PAGO - PROFESIONAL MEDICO
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
3.1. CREAR SP pi_Hon_CerrarPeriodoSolicitarPago
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pi_Hon_CerrarPeriodoSolicitarPago'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pi_Hon_CerrarPeriodoSolicitarPago TO PUBLIC
	DROP PROCEDURE honorario.pi_Hon_CerrarPeriodoSolicitarPago
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE OR ALTER PROCEDURE [honorario].[pi_Hon_CerrarPeriodoSolicitarPago]
@hon_Month int
,@hon_Year int
,@uni_Id uniqueidentifier
,@vin_Id uniqueidentifier
,@cbc_Id uniqueidentifier
-->Responsable
,@Usuario varchar(50)
AS
BEGIN
	SET NOCOUNT ON
	
DECLARE @_fechaActual AS DATETIME=GETDATE();


--declare @_version int
--select @_version=count(*) + 1 from [honorario].hon_Honorario hon where uni_Id=@uni_Id and vin_Id=@vin_Id and hon_Month=@hon_Month and hon_Year=@hon_Year and hon.hon_Eliminado=0


declare @_PorcImpuesto1 FLOAT
	SET @_PorcImpuesto1=14.5

	--select @_PorcImpuesto1


INSERT INTO [honorario].hon_Honorario
SELECT 
		NEWID()
		,hop.uni_Id
		,hop.sed_Id
		,hop.vin_Id
		,@cbc_Id --cbc_Id
		,@hon_Month--@hon_Month
		,@hon_Year--@hon_Year
		,MAX(hop.hop_Version)
		,SUM(hop.hop_SubtotalVenta) --hon_MontoVenta
		,SUM(hop_MontoDescuentoAVoluntad) --hon_TotalDescuento
		,SUM(hop_TotalVenta) --hon_SubTotalVenta
		,MIN(hop.hop_PorcConvenio) --hon_PorcConvenio
		,SUM(hop_MontoConvenio) --hon_TotalConvenio
		,SUM(hop_MontoDescuento1) --hon_MontoDescuento1
		,SUM(hop_MontoDescuento2) --hon_MontoDescuento2
		,0 --hon_MontoDescuentoOtros
		,null --hon_ConceptoDescuentoOtros
		,SUM(hop_Total) --hon_SubTotalConvenio
		,MIN(@_PorcImpuesto1) --hon_PorcImpuesto1 --DEBE VENIR DE UNA TABLA
		,(SUM(hop_Total) * @_PorcImpuesto1) /100  --hon_MontoImpuesto1
		,MIN('Impuesto por Honorarios Profesionales') --hon_ConceptoImpuesto1
		,0 --hon_PorcImpuesto2
		,0 --hon_MontoImpuesto2
		,NULL --hon_ConceptoImpuesto2
		,0 --hon_PorcImpuesto3
		,0 --hon_MontoImpuesto3
		,NULL --hon_ConceptoImpuesto3
		,SUM(hop_Total) - ((SUM(hop_Total) * @_PorcImpuesto1) /100) --hon_MontoTotal
		,1 --hon_AceptoPolitica
		,@_fechaActual --hon_FechaAceptoPolitica
		,NULL --hon_NotificaUni
		,NULL --hon_FechaNotificaUni
		,NULL --hon_MsgNotificaUni
		,@_fechaActual --hon_FechaCreacion --@_fechaActual 
		,@Usuario --hon_UsuarioCreacion
		,0 --hon_Eliminado
		,NULL --hon_FechaEliminacion
		,NULL --hon_UsuarioEliminacion
FROM  [honorario].hop_HonorarioProfesional hop
WHERE hop.hop_Eliminado=0
	AND hop_Month=@hon_Month
	AND hop_Year=@hon_Year
	AND hop.uni_Id=@uni_Id
	AND hop.vin_Id=@vin_Id
	and hop.hon_Id not in (select hon_Id from [honorario].phd_PagoHonorarioDetalle phd where phd.phn_Eliminado=0 and uni_Id=@uni_Id and phd.hon_Id=hop.hon_Id)
	and hop.hon_Id is null
GROUP BY 
		hop.uni_Id
		,hop.sed_Id
		,hop.vin_Id

UPDATE hop
	SET hop.hon_Id=hon.hon_Id
FROM [honorario].hop_HonorarioProfesional hop INNER JOIN [honorario].hon_Honorario hon
	ON hon.uni_Id=hop.uni_Id and hon.sed_Id=hop.sed_Id and hon.vin_Id=hop.vin_Id and hon.hon_Month=hop.hop_Month and hon.hon_Year=hop.hop_Year
		and hon.hon_Version=hop.hop_Version
WHERE hop.hop_Eliminado=0 and hon.hon_Eliminado=0

	
	SELECT 'OK' as Id

END

GO

GRANT  EXECUTE ON honorario.pi_Hon_CerrarPeriodoSolicitarPago TO PUBLIC

GO


/*====================================================================================================
3.2. CREAR SP ps_Hon_ValidarCerrarPeriodoSolicitarPago
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_ValidarCerrarPeriodoSolicitarPago'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_ValidarCerrarPeriodoSolicitarPago TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_ValidarCerrarPeriodoSolicitarPago
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[ps_Hon_ValidarCerrarPeriodoSolicitarPago]
@hon_Month int
,@hon_Year int
,@uni_Id uniqueidentifier
,@vin_Id uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT COUNT(hon.hon_Id) cant
	FROM [honorario].hon_Honorario hon
	WHERE hon.uni_Id=@uni_Id and hon.vin_Id=@vin_Id and hon.hon_Month=@hon_Month and hon.hon_Year=@hon_Year
		and hon.hon_Eliminado=0

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_ValidarCerrarPeriodoSolicitarPago TO PUBLIC

GO


/*====================================================================================================
3.3. CREAR SP ps_Hon_PendienteCierresSolicitarPagoPoVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_PendienteCierresSolicitarPagoPoVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_PendienteCierresSolicitarPagoPoVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_PendienteCierresSolicitarPagoPoVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE OR ALTER PROCEDURE [honorario].[ps_Hon_PendienteCierresSolicitarPagoPoVinId]
@uni_Id uniqueidentifier
,@vin_Id uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON

	declare @_PorcImpuesto1 FLOAT
	SET @_PorcImpuesto1=14.5
	
	SELECT * 
	
	FROM (
		SELECT uni_Id
				,vin_Id
				,hop_Month
				,hop_Year
				,hop.hop_Version
				,CASE WHEN hon_Id IS NULL THEN 0 ELSE 1 END hon_Estado
				,CASE WHEN hon_Id IS NULL THEN 'Período Pendiente por Cerrar' ELSE 'Período Cerrado - En Espera de Revisión' END hon_StrEstado
				,SUM(hop_SubtotalVenta) hop_SubtotalVenta
				,SUM(hop.hop_MontoDescuentoAVoluntad) hop_MontoDescuentoAVoluntad
				,SUM(hop.hop_TotalVenta) hop_TotalVenta
				,MIN(hop.hop_PorcConvenio) hop_PorcConvenio
				,SUM(hop.hop_MontoConvenio) hop_MontoConvenio
				,SUM(hop.hop_MontoDescuento1) hop_MontoDescuento1
				,SUM(hop.hop_Total) hop_Total
				,MIN(@_PorcImpuesto1) hon_PorcImpuesto1 --DEBE VENIR DE UNA TABLA
			    ,(SUM(hop_Total) * @_PorcImpuesto1) /100  hon_MontoImpuesto1
			    ,MIN('Impuesto por Honorarios Profesionales') hon_ConceptoImpuesto1
				,SUM(hop_Total) - ((SUM(hop_Total) * @_PorcImpuesto1) /100) hon_MontoTotal
				,MAX(hon_Id) hon_Id
		FROM[honorario].hop_HonorarioProfesional hop
		WHERE uni_Id=@uni_Id
			and vin_Id=@vin_Id
			and hop.hop_Eliminado=0
			and hop.hon_Id not in (select hon_Id from [honorario].phd_PagoHonorarioDetalle phd where phd.phn_Eliminado=0 and uni_Id=@uni_Id and phd.hon_Id=hop.hon_Id)
			--and hon_Id IS NULL
		GROUP BY uni_Id
				,vin_Id
				,hop_Month
				,hop_Year
				,hop.hop_Version
				,CASE WHEN hon_Id IS NULL THEN 0 ELSE 1 END
				,CASE WHEN hon_Id IS NULL THEN 'Período Pendiente por Cerrar' ELSE 'Período Cerrado - En Espera de Revisión' END
				) t1 LEFT JOIN [honorario].[hon_Honorario] hon
				ON hon.hon_Id=t1.hon_Id
		ORDER BY hop_Year DESC, hop_Month DESC, hop_Version DESC
				
      

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_PendienteCierresSolicitarPagoPoVinId TO PUBLIC

GO

/*====================================================================================================
3.4. CREAR SP ps_Hon_PendienteBoletaPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_PendienteBoletaPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_PendienteBoletaPorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_PendienteBoletaPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[ps_Hon_PendienteBoletaPorVinId]
@uni_Id uniqueidentifier
,@vin_Id uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
	--ESTO SE DEBE ORDENAR POR FECHA DE LA TABLA DE PAGO DE HONORARIO
	SELECT * FROM (
	SELECT phn.[phn_Id]
      ,hon.[uni_Id]
	  ,hon.[vin_Id]
      ,hon.[cbc_Id]
	  ,[hon_Month]
      ,[hon_Year]
	  ,phn.phn_Version
	  ,CASE WHEN phn.[phn_ImagenName] IS NULL THEN 0 ELSE 1 END hon_BoletaEmitida
	  ,ISNULL(phn.phn_Pagado, 0)  phn_Pagado
	  ,SUM(hon.hon_TotalConvenio) hon_TotalConvenio
	  ,SUM(hon.hon_MontoDescuento1) hon_MontoDescuento1
      ,SUM(hon.hon_MontoDescuentoOtros) hon_MontoDescuentoOtros
	  ,SUM(hon.hon_SubTotalConvenio) hon_SubTotalConvenio
	  ,MAX(hon.hon_PorcImpuesto1) hon_PorcImpuesto1
	  ,SUM(hon.hon_MontoImpuesto1) hon_MontoImpuesto1
	  ,SUM(hon.hon_MontoTotal) hon_MontoTotal
	  ,MAX(phn.phn_ComentarioUni) phn_ComentarioUni
	  ,MAX(phn.phn_DescripcionPago) phn_DescripcionPago
	  ,MAX(phn.phn_FechaCreacion) phn_FechaCreacion
  FROM [honorario].[hon_Honorario] hon INNER JOIN [unidadservicio].[sed_Sede] sed
		ON sed.sed_Id=hon.sed_Id INNER JOIN [honorario].[phd_PagoHonorarioDetalle] phd
		ON hon.hon_Id=phd.hon_Id INNER JOIN [honorario].[phn_PagoHonorario] phn
		ON phn.phn_Id=phd.phn_Id
	WHERE hon.hon_Eliminado=0
		and phd.phn_Eliminado=0
		and phn.phn_Eliminado=0
		--and phn.[phn_ImagenName] is null
		and hon.uni_Id=@uni_Id and hon.vin_Id=@vin_Id
	GROUP BY phn.[phn_Id]
      ,hon.[uni_Id]
	  ,hon.[vin_Id]
      ,hon.[cbc_Id]
	  ,[hon_Month]
      ,[hon_Year]
	  ,phn.phn_Version
	  ,CASE WHEN phn.[phn_ImagenName] IS NULL THEN 0 ELSE 1 END
	  ,ISNULL(phn.phn_Pagado, 0)) T1
	ORDER BY T1.phn_FechaCreacion DESC
      

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_PendienteBoletaPorVinId TO PUBLIC

GO

/*====================================================================================================
3.5. CREAR SP ps_Hon_PendienteBoletaDetallePorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_PendienteBoletaDetallePorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_PendienteBoletaDetallePorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_PendienteBoletaDetallePorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[ps_Hon_PendienteBoletaDetallePorVinId]
@phn_Id uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT sed.[sed_Id]
	  ,sed.[sed_Nombre]      
      ,hon.hon_TotalConvenio
	  ,hon.hon_MontoDescuento1
      ,hon.hon_MontoDescuentoOtros
	  ,hon.hon_SubTotalConvenio
	  ,hon.hon_PorcImpuesto1
	  ,hon.hon_MontoImpuesto1
	  ,hon.hon_MontoTotal
  FROM [honorario].[hon_Honorario] hon INNER JOIN [unidadservicio].[sed_Sede] sed
		ON sed.sed_Id=hon.sed_Id INNER JOIN [honorario].[phd_PagoHonorarioDetalle] phd
		ON hon.hon_Id=phd.hon_Id INNER JOIN [honorario].[phn_PagoHonorario] phn
		ON phn.phn_Id=phd.phn_Id
	WHERE hon.hon_Eliminado=0
		and phd.phn_Eliminado=0
		and phn.phn_Eliminado=0
		and phd.phn_Id=@phn_Id
	ORDER BY  [hon_Year] DESC,[hon_Month] DESC
      

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_PendienteBoletaDetallePorVinId TO PUBLIC

GO


/*====================================================================================================
------------------------------------------------------------------------------------------------------
4- HONORARIOS REVISION POR PARTE DE LA UNIDAD CLINICA
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
4.1. CREAR SP ps_Hon_HeaderHonorariosPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_HeaderHonorariosPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_HeaderHonorariosPorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_HeaderHonorariosPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

--  exec [honorario].[ps_Hon_HeaderHonorariosPorVinId] 4, 2021, '863C4678-B9B2-474E-A913-D1526D7CCBBE'

CREATE PROCEDURE [honorario].[ps_Hon_HeaderHonorariosPorVinId]
@hon_Month int
,@hon_Year int
,@vinId uniqueidentifier
,@uniId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
		SELECT 	
			hon.hon_Id
			,hon.uni_Id
			,hon.sed_Id
			,hon.sed_Id
			,sed.sed_Nombre
			,hon.vin_Id
			,hon.hon_Month
			,hon.hon_Year

			,hon.hon_MontoVenta
			,hon.hon_TotalDescuento
			,hon.hon_SubTotalVenta
			,hon.hon_TotalConvenio
			,hon.hon_MontoDescuento1
			,hon.hon_MontoDescuento2
			,hon.hon_MontoDescuentoOtros
			,hon.hon_ConceptoDescuentoOtros
			,hon.hon_SubTotalConvenio
			,hon.hon_PorcImpuesto1
			,hon.hon_MontoImpuesto1
			,hon.hon_ConceptoImpuesto1
			,hon.hon_PorcImpuesto2
			,hon.hon_MontoImpuesto2
			,hon.hon_ConceptoImpuesto2
			,hon.hon_PorcImpuesto3
			,hon.hon_MontoImpuesto3
			,hon.hon_ConceptoImpuesto3
			,hon.hon_MontoTotal	
			,hon.hon_Version
			,(select count(*) from [honorario].[phd_PagoHonorarioDetalle] phd where phd.phn_Eliminado=0 and phd.hon_Id=hon.hon_Id) hon_CantidadDetalle
		FROM [honorario].hon_Honorario hon INNER JOIN [unidadservicio].[vin_Vinculacion] vin
			ON vin.vin_Id=hon.vin_Id INNER JOIN [unidadservicio].[sed_Sede] sed
			ON sed.sed_Id=hon.sed_Id
		WHERE hon.hon_Eliminado=0
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
			and hon.vin_Id=@vinId
		ORDER BY hon.hon_Version DESC

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_HeaderHonorariosPorVinId TO PUBLIC

GO

/*====================================================================================================
4.1. CREAR SP ps_Hon_HeaderHonorariosVersionPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_HeaderHonorariosVersionPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_HeaderHonorariosVersionPorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_HeaderHonorariosVersionPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

--  exec [honorario].[ps_Hon_HeaderHonorariosPorVinId] 4, 2021, '863C4678-B9B2-474E-A913-D1526D7CCBBE'

CREATE PROCEDURE [honorario].[ps_Hon_HeaderHonorariosVersionPorVinId]
@hon_Month int
,@hon_Year int
,@vinId uniqueidentifier
,@uniId uniqueidentifier
,@hon_Version int
AS
BEGIN
	SET NOCOUNT ON
	
		SELECT 	
			hon.hon_Id
			,hon.uni_Id
			,hon.sed_Id
			,hon.sed_Id
			,sed.sed_Nombre
			,hon.vin_Id
			,hon.hon_Month
			,hon.hon_Year

			,hon.hon_MontoVenta
			,hon.hon_TotalDescuento
			,hon.hon_SubTotalVenta
			,hon.hon_TotalConvenio
			,hon.hon_MontoDescuento1
			,hon.hon_MontoDescuento2
			,hon.hon_MontoDescuentoOtros
			,hon.hon_ConceptoDescuentoOtros
			,hon.hon_SubTotalConvenio
			,hon.hon_PorcImpuesto1
			,hon.hon_MontoImpuesto1
			,hon.hon_ConceptoImpuesto1
			,hon.hon_PorcImpuesto2
			,hon.hon_MontoImpuesto2
			,hon.hon_ConceptoImpuesto2
			,hon.hon_PorcImpuesto3
			,hon.hon_MontoImpuesto3
			,hon.hon_ConceptoImpuesto3
			,hon.hon_MontoTotal	
			,hon.hon_Version
			,(select count(*) from [honorario].[phd_PagoHonorarioDetalle] phd where phd.phn_Eliminado=0 and phd.hon_Id=hon.hon_Id) hon_CantidadDetalle
		FROM [honorario].hon_Honorario hon INNER JOIN [unidadservicio].[vin_Vinculacion] vin
			ON vin.vin_Id=hon.vin_Id INNER JOIN [unidadservicio].[sed_Sede] sed
			ON sed.sed_Id=hon.sed_Id
		WHERE hon.hon_Eliminado=0
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
			and hon.vin_Id=@vinId
			and hon.hon_Version=@hon_Version
		ORDER BY hon.hon_Version DESC

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_HeaderHonorariosVersionPorVinId TO PUBLIC

GO

/*====================================================================================================
4.2. CREAR SP ps_Hop_BodyHonorariosPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hop_BodyHonorariosPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hop_BodyHonorariosPorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hop_BodyHonorariosPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

--  exec [honorario].[ps_Hod_BodyHonorariosPorVinId] 4, 2021, '45d1754a-55c6-46be-9e21-71c1776c5c3e', '863C4678-B9B2-474E-A913-D1526D7CCBBE'

CREATE PROCEDURE [honorario].[ps_Hop_BodyHonorariosPorVinId]
@hon_Month int
,@hon_Year int
,@vinId uniqueidentifier
,@uniId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
		--SELECT 	
		--	hod.hod_Id
		--	,hon.hon_Id
		--	,hon.sed_Id
		--	,hon.sed_Id
		--	,sed.sed_Nombre
		--	,fpa.fpa_Id
		--	,fpa.fpa_Nombre
		--	,ser.ser_Id
		--	,ser.[ser_Nombre]
		--	,pac.pac_Nombre + ' ' + pac.pac_Apellido as pac_FullName
		--	,CASE WHEN pac.[pac_Identificacion] IS NULL THEN 'S/I' ELSE tid.tid_Descripcion + ' ' + pac.[pac_Identificacion] END as pac_Identificacion

		--	,hod.hod_SubtotalVenta
		--	,hod.hod_PorcDescuentoAVoluntad
		--	,hod.hod_MontoDescuentoAVoluntad
		--	,hod.hod_ConceptoDescuentoAVoluntad
		--	,hod.hod_ResponsableDescuento
		--	,hod.hod_TotalVenta
		--	,hod.hod_PorcConvenio
		--	,hod.hod_MontoConvenio
		--	,hod.hod_PorcDescuento1
		--	,hod.hod_MontoDescuento1
		--	,hod.hod_ConceptoDescuento1
		--	,hod.hod_PorcDescuento2
		--	,hod.hod_MontoDescuento2
		--	,hod.hod_ConceptoDescuento2
		--	,hod.hod_Total
		--	,hod.hod_Descripcion
		--	,CASE WHEN hod.[hod_Eliminado]=1 THEN 'Eliminado' ELSE 'Vigente' END hod_Estatus
		--FROM [honorario].hon_Honorario hon INNER JOIN [unidadservicio].[vin_Vinculacion] vin
		--	ON vin.vin_Id=hon.vin_Id INNER JOIN [unidadservicio].[sed_Sede] sed
		--	ON sed.sed_Id=hon.sed_Id INNER JOIN [honorario].[hod_HonorarioDetalle] hod
		--	ON hon.hon_Id=hod.hon_Id INNER JOIN [factura].[fpa_FormaPago] fpa
		--	ON fpa.fpa_Id=hod.fpa_Id INNER JOIN [unidadservicio].[ser_Servicio] ser
		--	ON ser.ser_Id=hod.ser_Id INNER JOIN [factura].[fad_FacturaDetalle] fad
		--	ON fad.fad_Id=hod.fad_Id INNER JOIN [factura].[fac_Factura] fac
		--	ON fac.fac_Id=fad.fac_Id INNER JOIN [paciente].[pac_Paciente] pac
		--	ON pac.pac_Id=fac.pac_Id INNER JOIN [utilitario].[tid_TipoIdentificacion] tid
		--	ON tid.tid_Id=pac.tid_Id
		--WHERE hon.hon_Eliminado=0
		--	and hon.uni_Id=@uniId
		--	and hon.hon_Year=@hon_Year
		--	and hon.hon_Month=@hon_Month
		--	and hon.vin_Id=@vinId	
			

			SELECT 	
			hop.hop_Id
			,hon.hon_Id
			,hon.sed_Id
			,hon.sed_Id
			,sed.sed_Nombre
			,fpa.fpa_Id
			,fpa.fpa_Nombre
			,ser.ser_Id
			--,ser.[ser_Nombre]
			,CASE WHEN ser.ser_EsExpress=1 THEN cat.cat_Nombre + ' - ' + sdd.[sdd_Descripcion] ELSE cat.cat_Nombre + ' - ' + ser.ser_Nombre END as ser_Nombre
			,pac.pac_Nombre + ' ' + pac.pac_Apellido as pac_FullName
			,CASE WHEN pac.[pac_Identificacion] IS NULL THEN 'S/I' ELSE tid.tid_Descripcion + ' ' + pac.[pac_Identificacion] END as pac_Identificacion

			,hop.hop_SubtotalVenta
			,hop.hop_PorcDescuentoAVoluntad
			,hop.hop_MontoDescuentoAVoluntad
			,hop.hop_ConceptoDescuentoAVoluntad
			,hop.hop_ResponsableDescuento
			,hop.hop_TotalVenta
			,hop.hop_PorcConvenio
			,hop.hop_MontoConvenio
			,hop.hop_PorcDescuento1
			,hop.hop_MontoDescuento1
			,hop.hop_ConceptoDescuento1
			,hop.hop_PorcDescuento2
			,hop.hop_MontoDescuento2
			,hop.hop_ConceptoDescuento2
			,hop.hop_Total
			,hop.hop_Descripcion
			,CASE WHEN hop.[hop_Eliminado]=1 THEN 'Eliminado' ELSE 'Vigente' END hod_Estatus
			,hop.hop_Version
		FROM [honorario].hon_Honorario hon INNER JOIN [unidadservicio].[vin_Vinculacion] vin
			ON vin.vin_Id=hon.vin_Id INNER JOIN [unidadservicio].[sed_Sede] sed
			ON sed.sed_Id=hon.sed_Id INNER JOIN [honorario].[hop_HonorarioProfesional] hop
			ON hon.hon_Id=hop.hon_Id INNER JOIN [factura].[fpa_FormaPago] fpa
			ON fpa.fpa_Id=hop.fpa_Id INNER JOIN [unidadservicio].[ser_Servicio] ser
			ON ser.ser_Id=hop.ser_Id INNER JOIN [factura].[fad_FacturaDetalle] fad
			ON fad.fad_Id=hop.fad_Id INNER JOIN [factura].[fac_Factura] fac
			ON fac.fac_Id=fad.fac_Id INNER JOIN [paciente].[pac_Paciente] pac
			ON pac.pac_Id=fac.pac_Id INNER JOIN [utilitario].[tid_TipoIdentificacion] tid
			ON tid.tid_Id=pac.tid_Id INNER JOIN [unidadservicio].[cat_Categoria] cat
			ON cat.[cat_Id]=ser.[cat_Id] INNER JOIN [gestion].[sdd_ServicioDiagnosticoDetalle] sdd
			ON sdd.[sdd_Id]=fad.[sdd_Id]
		WHERE hon.hon_Eliminado=0
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
			and hon.vin_Id=@vinId
		ORDER BY hop.hop_Version DESC, (pac.pac_Nombre + ' ' + pac.pac_Apellido) DESC

END

GO

GRANT  EXECUTE ON honorario.ps_Hop_BodyHonorariosPorVinId TO PUBLIC

GO

/*====================================================================================================
4.2. CREAR SP ps_Hop_BodyHonorariosVersionPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hop_BodyHonorariosVersionPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hop_BodyHonorariosVersionPorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hop_BodyHonorariosVersionPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

--  exec [honorario].[ps_Hod_BodyHonorariosPorVinId] 4, 2021, '45d1754a-55c6-46be-9e21-71c1776c5c3e', '863C4678-B9B2-474E-A913-D1526D7CCBBE'

CREATE PROCEDURE [honorario].[ps_Hop_BodyHonorariosVersionPorVinId]
@hon_Month int
,@hon_Year int
,@vinId uniqueidentifier
,@uniId uniqueidentifier
,@hon_Version int
AS
BEGIN
	SET NOCOUNT ON
	
		
			

			SELECT 	
			hop.hop_Id
			,hon.hon_Id
			,hon.sed_Id
			,hon.sed_Id
			,sed.sed_Nombre
			,fpa.fpa_Id
			,fpa.fpa_Nombre
			,ser.ser_Id
			--,ser.[ser_Nombre]
			,CASE WHEN ser.ser_EsExpress=1 THEN cat.cat_Nombre + ' - ' + sdd.[sdd_Descripcion] ELSE cat.cat_Nombre + ' - ' + ser.ser_Nombre END as ser_Nombre
			,pac.pac_Nombre + ' ' + pac.pac_Apellido as pac_FullName
			,CASE WHEN pac.[pac_Identificacion] IS NULL THEN 'S/I' ELSE tid.tid_Descripcion + ' ' + pac.[pac_Identificacion] END as pac_Identificacion

			,hop.hop_SubtotalVenta
			,hop.hop_PorcDescuentoAVoluntad
			,hop.hop_MontoDescuentoAVoluntad
			,hop.hop_ConceptoDescuentoAVoluntad
			,hop.hop_ResponsableDescuento
			,hop.hop_TotalVenta
			,hop.hop_PorcConvenio
			,hop.hop_MontoConvenio
			,hop.hop_PorcDescuento1
			,hop.hop_MontoDescuento1
			,hop.hop_ConceptoDescuento1
			,hop.hop_PorcDescuento2
			,hop.hop_MontoDescuento2
			,hop.hop_ConceptoDescuento2
			,hop.hop_Total
			,hop.hop_Descripcion
			,CASE WHEN hop.[hop_Eliminado]=1 THEN 'Eliminado' ELSE 'Vigente' END hod_Estatus
			,hop.hop_Version
		FROM [honorario].hon_Honorario hon INNER JOIN [unidadservicio].[vin_Vinculacion] vin
			ON vin.vin_Id=hon.vin_Id INNER JOIN [unidadservicio].[sed_Sede] sed
			ON sed.sed_Id=hon.sed_Id INNER JOIN [honorario].[hop_HonorarioProfesional] hop
			ON hon.hon_Id=hop.hon_Id INNER JOIN [factura].[fpa_FormaPago] fpa
			ON fpa.fpa_Id=hop.fpa_Id INNER JOIN [unidadservicio].[ser_Servicio] ser
			ON ser.ser_Id=hop.ser_Id INNER JOIN [factura].[fad_FacturaDetalle] fad
			ON fad.fad_Id=hop.fad_Id INNER JOIN [factura].[fac_Factura] fac
			ON fac.fac_Id=fad.fac_Id INNER JOIN [paciente].[pac_Paciente] pac
			ON pac.pac_Id=fac.pac_Id INNER JOIN [utilitario].[tid_TipoIdentificacion] tid
			ON tid.tid_Id=pac.tid_Id INNER JOIN [unidadservicio].[cat_Categoria] cat
			ON cat.[cat_Id]=ser.[cat_Id] INNER JOIN [gestion].[sdd_ServicioDiagnosticoDetalle] sdd
			ON sdd.[sdd_Id]=fad.[sdd_Id]
		WHERE hon.hon_Eliminado=0
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
			and hon.vin_Id=@vinId
			and hon.hon_Version=@hon_Version
		ORDER BY hop.hop_Version DESC

END

GO

GRANT  EXECUTE ON honorario.ps_Hop_BodyHonorariosVersionPorVinId TO PUBLIC

GO

/*====================================================================================================
4.3. CREAR SP pu_Hon_DescuentosOtrosId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pu_Hon_DescuentosOtrosId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pu_Hon_DescuentosOtrosId TO PUBLIC
	DROP PROCEDURE honorario.pu_Hon_DescuentosOtrosId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[pu_Hon_DescuentosOtrosId]
@honId uniqueidentifier
,@honMontoDescuentoOtros MONEY
,@honConceptoDescuentoOtros VARCHAR(255)
,@honMontoTotal MONEY
-->Responsable
,@Usuario varchar(50)
AS
BEGIN
	SET NOCOUNT ON
	
	UPDATE [honorario].[hon_Honorario]
		SET [hon_MontoDescuentoOtros]=@honMontoDescuentoOtros
		,[hon_ConceptoDescuentoOtros]=@honConceptoDescuentoOtros
		,[hon_SubTotalConvenio]=([hon_TotalConvenio] - ([hon_MontoDescuento1] + [hon_MontoDescuento2] + @honMontoDescuentoOtros))
		,[hon_MontoImpuesto1]=(([hon_TotalConvenio] - ([hon_MontoDescuento1] + [hon_MontoDescuento2] + @honMontoDescuentoOtros)) * [hon_PorcImpuesto1])/100
		,[hon_MontoTotal]= ([hon_TotalConvenio] - ([hon_MontoDescuento1] + [hon_MontoDescuento2] + @honMontoDescuentoOtros)) - (([hon_TotalConvenio] - ([hon_MontoDescuento1] + [hon_MontoDescuento2] + @honMontoDescuentoOtros)) * [hon_PorcImpuesto1])/100
	WHERE [hon_Id]=@honId

	select 'OK' Id

END

GO

GRANT  EXECUTE ON honorario.pu_Hon_DescuentosOtrosId TO PUBLIC

GO

/*====================================================================================================
4.4. CREAR SP pu_Hod_Descuento1PorId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pu_Hod_Descuento1PorId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pu_Hod_Descuento1PorId TO PUBLIC
	DROP PROCEDURE honorario.pu_Hod_Descuento1PorId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[pu_Hod_Descuento1PorId]
@hodId uniqueidentifier
,@hodPorcoDescuento MONEY
,@hodMontoDescuento MONEY
,@hodConceptoDescuento VARCHAR(255)
-->Responsable
,@Usuario varchar(50)
AS
BEGIN
	SET NOCOUNT ON
	
	UPDATE [honorario].[hod_HonorarioDetalle]
		SET [hod_PorcDescuento2]=@hodPorcoDescuento
		,[hod_MontoDescuento2]=@hodMontoDescuento
		,[hod_ConceptoDescuento2]=@hodConceptoDescuento
		,[hod_Total]=([hod_MontoConvenio] - ([hod_MontoDescuento1] + @hodMontoDescuento))
	WHERE [hod_Id]=@hodId

	select 'OK' Id

END

GO

GRANT  EXECUTE ON honorario.pu_Hod_Descuento1PorId TO PUBLIC

GO


/*====================================================================================================
4.5. CREAR SP ps_Hon_RecalculoPorMesPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_RecalculoPorMesPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_RecalculoPorMesPorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_RecalculoPorMesPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[ps_Hon_RecalculoPorMesPorVinId]
@hon_Month int
,@hon_Year int
,@_vinId uniqueidentifier
,@_uniId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
	--CREATE TABLE #temp_hon_HonorarioTotales (hon_Id uniqueidentifier
	--									 ,hon_MontoVenta money NOT NULL
	--									 ,hon_TotalDescuento money NOT NULL
	--									 ,hon_SubTotalVenta money NOT NULL
	--									 ,hon_TotalConvenio money NOT NULL
	--									 ,hon_MontoDescuento1 money NOT NULL
	--									 ,hon_MontoDescuento2 money NOT NULL
	--									 ,hon_SubTotalConvenio money NOT NULL
	--									 ,hon_PorcImpuesto1 money NOT NULL
	--									 ,hon_MontoImpuesto1 money NOT NULL
	--									 ,hon_ConceptoImpuesto1 varchar(100) NULL
	--									 ,hon_MontoTotal money NOT NULL);
										 
	--Declare @vinId uniqueidentifier,
	--	@uniId varchar(200),
	--	@sedId varchar(150),
	--	@honId uniqueidentifier
	--Declare pmeBase cursor GLOBAL
	--for Select uni_Id, sed_Id, vin_Id, hon_Id from [honorario].[hon_Honorario] where [uni_Id]=@_uniId and [vin_Id]=@_vinId and [hon_Month]=@hon_Month and [hon_Year]=@hon_Year
	--Open pmeBase
	--fetch pmeBase into @uniId, @sedId, @vinId, @honId
	--while(@@fetch_status=0)
	--begin
	
	--		DELETE FROM #temp_hon_HonorarioTotales

	--		INSERT INTO #temp_hon_HonorarioTotales
	--		SELECT @honId
	--			,SUM(hod.hod_SubtotalVenta)
	--			,SUM(hod_MontoDescuentoAVoluntad)
	--			,SUM(hod_TotalVenta)
	--			,SUM(hod_MontoConvenio)
	--			,SUM(hod_MontoDescuento1)
	--			,SUM(hod_MontoDescuento2)
	--			,SUM(hod_Total)
	--			,MIN(11.50) --DEBE VENIR DE UNA TABLA
	--			,(SUM(hod_Total) * 11.50) /100 
	--			,MIN('Impuesto por Honorarios Profesionales')
	--			,SUM(hod_Total) - ((SUM(hod_Total) * 11.50) /100)
	--		FROM [honorario].hon_Honorario hon INNER JOIN [honorario].[hod_HonorarioDetalle] hod
	--			ON hon.hon_Id=hod.hon_Id
	--		WHERE hon.hon_Eliminado=0 and hod.hod_Eliminado=0
	--			and hon.hon_Id=@honId

	--		UPDATE hon
	--		SET hon.hon_MontoVenta= tem.hon_MontoVenta
	--			,hon.hon_TotalDescuento= tem.hon_TotalDescuento
	--			,hon.hon_SubTotalVenta= tem.hon_SubTotalVenta
	--			,hon.hon_TotalConvenio= tem.hon_TotalConvenio
	--			,hon.hon_MontoDescuento1= tem.hon_MontoDescuento1
	--			,hon.hon_MontoDescuento2= tem.hon_MontoDescuento2
	--			,hon_SubTotalConvenio= tem.hon_SubTotalConvenio - hon.hon_MontoDescuentoOtros
	--			,hon.hon_PorcImpuesto1= tem.hon_PorcImpuesto1
	--			,hon.hon_MontoImpuesto1= (((tem.hon_SubTotalConvenio - hon.hon_MontoDescuentoOtros) * tem.hon_PorcImpuesto1)/100)
	--			,hon.hon_ConceptoImpuesto1= tem.hon_ConceptoImpuesto1
	--			,hon.hon_MontoTotal= ((tem.hon_SubTotalConvenio - hon.hon_MontoDescuentoOtros) - ((tem.hon_SubTotalConvenio - hon.hon_MontoDescuentoOtros) * tem.hon_PorcImpuesto1)/100)
	--		FROM [honorario].hon_Honorario hon INNER JOIN #temp_hon_HonorarioTotales tem
	--			ON hon.hon_Id=tem.hon_Id

		
	
	


	--fetch pmeBase into @uniId, @sedId, @vinId, @honId
	--end
	--close pmeBase
	--deallocate pmeBase
	
		
	--DROP TABLE #temp_hon_HonorarioTotales

	--SELECT 'OK' as Id

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_RecalculoPorMesPorVinId TO PUBLIC

GO


/*====================================================================================================
4.6. CREAR SP pi_Phn_PagoHonorario
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pi_Phn_PagoHonorario'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pi_Phn_PagoHonorario TO PUBLIC
	DROP PROCEDURE honorario.pi_Phn_PagoHonorario
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[pi_Phn_PagoHonorario]
@uni_Id uniqueidentifier
,@vin_Id uniqueidentifier
,@hon_Month int
,@hon_Year int
,@cbc_Id uniqueidentifier
,@phn_ComentarioUni varchar(255)
-->Responsable
,@Usuario varchar(50)
,@hon_Version int
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @_fechaActual AS DATETIME=GETDATE();

	DECLARE @_ID AS UNIQUEIDENTIFIER
	SET @_ID=NEWID();

	INSERT INTO [honorario].phn_PagoHonorario (phn_Id, uni_Id, vin_Id, cbc_Id, phn_Month, phn_Year, phn_Version, phn_ComentarioUni, phn_FechaCreacion, phn_UsuarioCreacion, phn_Eliminado, phn_FechaEliminacion, phn_UsuarioEliminacion)
	VALUES (@_ID, @uni_Id, @vin_Id, @cbc_Id, @hon_Month, @hon_Year, @hon_Version, @phn_ComentarioUni, @_fechaActual, @Usuario, 0, NULL, NULL);

	IF (SELECT COUNT(*) FROM [honorario].phn_PagoHonorario phn WHERE phn.phn_Id=@_ID) > 0
	BEGIN

		INSERT INTO [honorario].phd_PagoHonorarioDetalle
		SELECT NEWID()
			,@uni_Id
			,hon.hon_Id
			,@_ID
			,@_fechaActual
			,@Usuario
			,0
			,null
			,null
		FROM [honorario].[hon_Honorario] hon
		WHERE hon.hon_Eliminado=0
			AND hon_Id NOT IN(SELECT phd.hon_Id FROM [honorario].phd_PagoHonorarioDetalle phd WHERE phd.hon_Id=hon.hon_Id and phd.phn_Eliminado=0)
			AND hon.uni_Id=@uni_Id
			AND hon.vin_Id=@vin_Id
			AND hon.hon_Year=@hon_Year
			AND hon.hon_Month=@hon_Month
			AND hon.hon_Version=@hon_Version
	
		SELECT 'OK' as Id

	END
	ELSE
	BEGIN

		SELECT 'ER' AS Id

	END;

	

END

GO

GRANT  EXECUTE ON honorario.pi_Phn_PagoHonorario TO PUBLIC

GO

/*====================================================================================================
4.7. CREAR SP ps_Hon_ValidaCuentaHonorarioPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_ValidaCuentaHonorarioPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_ValidaCuentaHonorarioPorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_ValidaCuentaHonorarioPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[ps_Hon_ValidaCuentaHonorarioPorVinId]
@uniId uniqueidentifier
,@vinId uniqueidentifier
,@hon_Month int
,@hon_Year int
AS
BEGIN
	SET NOCOUNT ON
	

		SELECT DISTINCT cbc.cbc_Id
				,ban.ban_Nombre
				,tcb.tcb_Nombre
				,cbc.cbc_NombreTitular
				,cbc.cbc_NroCuenta
				,cbc.cbc_Email
		FROM [honorario].hon_Honorario hon INNER JOIN [profesionalmedico].[cbc_CuentaBancaria] cbc
			ON cbc.cbc_Id=hon.cbc_Id INNER JOIN [utilitario].[ban_Banco] ban
			ON ban.ban_Id=cbc.ban_Id INNER JOIN [utilitario].[tcb_TipoCuentaBancaria] tcb
			ON tcb.tcb_Id=cbc.tcb_Id
		WHERE hon.hon_Eliminado=0
			and cbc.cbc_Eliminado=0
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
			and hon.vin_Id=@vinId

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_ValidaCuentaHonorarioPorVinId TO PUBLIC

GO


/*====================================================================================================
4.8. CREAR SP ps_Hon_ValidarAprobacionPagoPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_Hon_ValidarAprobacionPagoPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_Hon_ValidarAprobacionPagoPorVinId TO PUBLIC
	DROP PROCEDURE honorario.ps_Hon_ValidarAprobacionPagoPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[ps_Hon_ValidarAprobacionPagoPorVinId]
@uniId uniqueidentifier
,@vinId uniqueidentifier
,@hon_Month int
,@hon_Year int
AS
BEGIN
	SET NOCOUNT ON
	

		SELECT DISTINCT phn.phn_Id
			,CASE WHEN phn.phn_ImagenName is null THEN 0 ELSE 1 END phn_BoletaAdjunta
			,ISNULL(phn.phn_Pagado,0) phn_Pagado
		FROM [honorario].hon_Honorario hon INNER JOIN [honorario].[phd_PagoHonorarioDetalle] phd
			ON phd.hon_Id=hon.hon_Id INNER JOIN [honorario].[phn_PagoHonorario] phn
			ON phn.phn_Id=phd.phn_Id
		WHERE hon.hon_Eliminado=0
			and phd.phn_Eliminado=0
			and phn.phn_Eliminado=0
			--and phn.phn_ImagenName is null
			and hon.uni_Id=@uniId
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
			and hon.vin_Id=@vinId

END

GO

GRANT  EXECUTE ON honorario.ps_Hon_ValidarAprobacionPagoPorVinId TO PUBLIC

GO

/*====================================================================================================
4.9. CREAR SP pu_Hon_AnularAprobacionPagoPorVinId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pu_Hon_AnularAprobacionPagoPorVinId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pu_Hon_AnularAprobacionPagoPorVinId TO PUBLIC
	DROP PROCEDURE honorario.pu_Hon_AnularAprobacionPagoPorVinId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[pu_Hon_AnularAprobacionPagoPorVinId]
@uni_Id uniqueidentifier
,@vin_Id uniqueidentifier
,@hon_Month int
,@hon_Year int
-->Responsable
,@Usuario varchar(50)
,@hon_Version int
AS
BEGIN
	SET NOCOUNT ON
	

		UPDATE phd
			SET phd.phn_Eliminado=1
				,phd.phn_FechaEliminacion=GETDATE()
				,phd.phn_UsuarioEliminacion=@Usuario
		FROM [honorario].hon_Honorario hon INNER JOIN [honorario].[phd_PagoHonorarioDetalle] phd
			ON phd.hon_Id=hon.hon_Id INNER JOIN [honorario].[phn_PagoHonorario] phn
			ON phn.phn_Id=phd.phn_Id
		WHERE hon.uni_Id=@uni_Id
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
			and hon.vin_Id=@vin_Id
			and ISNULL(phn.phn_Pagado,0)=0
			and phn_Version=@hon_Version

		UPDATE phn
			SET phn.phn_Eliminado=1
				,phn.phn_FechaEliminacion=GETDATE()
				,phn.phn_UsuarioEliminacion=@Usuario
		FROM [honorario].hon_Honorario hon INNER JOIN [honorario].[phd_PagoHonorarioDetalle] phd
			ON phd.hon_Id=hon.hon_Id INNER JOIN [honorario].[phn_PagoHonorario] phn
			ON phn.phn_Id=phd.phn_Id
		WHERE hon.uni_Id=@uni_Id
			and hon.hon_Year=@hon_Year
			and hon.hon_Month=@hon_Month
			and hon.vin_Id=@vin_Id
			and ISNULL(phn.phn_Pagado,0)=0
			and phn_Version=@hon_Version

			select 'OK' as Id

END

GO

GRANT  EXECUTE ON honorario.pu_Hon_AnularAprobacionPagoPorVinId TO PUBLIC

GO

/*====================================================================================================
4.10. CREAR SP pu_phn_PagarHonorarios
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pu_phn_PagarHonorarios'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pu_phn_PagarHonorarios TO PUBLIC
	DROP PROCEDURE honorario.pu_phn_PagarHonorarios
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[pu_phn_PagarHonorarios]
@uni_Id uniqueidentifier
,@vin_Id uniqueidentifier
,@hon_Month int
,@hon_Year int
,@cbc_Id uniqueidentifier
,@phn_MontoPagado money
,@phn_DescripcionPago varchar(500)
,@hon_Id uniqueidentifier
,@phn_Version int
AS
BEGIN
	SET NOCOUNT ON
	
	UPDATE phn
		SET phn_MontoPagado=@phn_MontoPagado
			,phn_DescripcionPago=@phn_DescripcionPago
			,phn_Pagado=1
	FROM [honorario].phn_PagoHonorario phn INNER JOIN [honorario].[phd_PagoHonorarioDetalle] phd
		ON phn.phn_Id=phd.phn_Id
	WHERE phn.uni_Id=@uni_Id and phn.vin_Id=@vin_Id and cbc_Id=@cbc_Id and phn_Month=@hon_Month and phn_Year=@hon_Year
		and phn.phn_Eliminado=0
		and ISNULL(phn_Pagado,0)=0
		and phd.phn_Eliminado=0
		and phd.hon_Id=@hon_Id
		and phn.phn_Version=@phn_Version

	select 'OK' AS Id

END

GO

GRANT  EXECUTE ON honorario.pu_phn_PagarHonorarios TO PUBLIC

GO


/*====================================================================================================
------------------------------------------------------------------------------------------------------
5- DETALLE DE HONORARIOS NUEVO
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
5.1. CREAR SP pi_hop_HonorarioProfesional
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pi_hop_HonorarioProfesional'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pi_hop_HonorarioProfesional TO PUBLIC
	DROP PROCEDURE honorario.pi_hop_HonorarioProfesional
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[pi_hop_HonorarioProfesional]
@uniId uniqueidentifier
,@vinId uniqueidentifier

,@hon_Month int
,@hon_Year int

,@usuario varchar(50)

--Filtro
,@fadId uniqueidentifier

AS
BEGIN
	SET NOCOUNT ON
	
	INSERT INTO [honorario].hop_HonorarioProfesional
	SELECT 
			NEWID() --hop_Id]
			,@uniId --uni_Id
			,con.sed_Id --sed_Id
			,@vinId --vin_Id
			
			,fad.fad_Id --fad_Id
			--,(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) as fpa_Id --fpa_Id --Obtiene la forma de pago del monto mas alto.
			,CASE WHEN (select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) IS NULL THEN (SELECT [fpa_Id] FROM [factura].[fpa_FormaPago] fpa where fpa.uni_Id=fac.uni_Id and fpa.fpa_Principal=1) ELSE (select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) END as fpa_Id --fpa_Id --Obtiene la forma de pago del monto mas alto.
			,ser.ser_Id --ser_Id
			,pio.[cvo_Id] --cvo_Id
			,null --hon_Id

			,@hon_Month --hop_Month
			,@hon_Year --hop_Year
			,(select count(*) + 1 from [honorario].hon_Honorario hon where hon.uni_Id=@uniId and hon.vin_Id=@vinId and hon.hon_Month=@hon_Month and hon.hon_Year=@hon_Year and hon.hon_Eliminado=0)--hop_Version
		
			,fad.fad_Subtotal --hop_SubtotalVenta
			

			,sdd.sdd_PorcDescuento --hop_PorcDescuentoAVoluntad
			,sdd.sdd_MontoDescuento -- hop_MontoDescuentoAVoluntad
			,sdd.[sdd_MotivoDescuento] -- hop_ConceptoDescuentoAVoluntad
			,sdd.sdd_ResponsableDescuento --hop_ResponsableDescuento

			,fad.fad_Total		--hop_TotalVenta
			,vin.[vin_PorcConvenio] --hop_PorcConvenio
			--,(fad.fad_Total * vin.[vin_PorcConvenio])/100 as hod_MontoConvenio --hop_MontoConvenio
			--,CASE WHEN sdd.sdd_ResponsableDescuento='ALL' THEN ((fad.fad_Total * vin.[vin_PorcConvenio])/100) ELSE
			--	CASE WHEN sdd.sdd_ResponsableDescuento='UNI' THEN ((fad.fad_Subtotal * vin.[vin_PorcConvenio])/100) ELSE
			--	CASE WHEN sdd.sdd_ResponsableDescuento='PME' THEN (fad.fad_Total - (((fad.fad_Subtotal * (100 - vin.[vin_PorcConvenio]))/100))) ELSE ((fad.fad_Total * vin.[vin_PorcConvenio])/100) END END END AS hod_MontoConvenio --hop_MontoConvenio
			,CASE WHEN ser.ser_FullHonorarioProfesional=1 THEN fad.fad_Total ELSE CASE WHEN sdd.sdd_ResponsableDescuento='ALL' THEN ((fad.fad_Total * vin.[vin_PorcConvenio])/100) ELSE
				CASE WHEN sdd.sdd_ResponsableDescuento='UNI' THEN ((fad.fad_Subtotal * vin.[vin_PorcConvenio])/100) ELSE
				CASE WHEN sdd.sdd_ResponsableDescuento='PME' THEN (fad.fad_Total - (((fad.fad_Subtotal * (100 - vin.[vin_PorcConvenio]))/100))) ELSE ((fad.fad_Total * vin.[vin_PorcConvenio])/100) END END END END AS hod_MontoConvenio --hop_MontoConvenio

			,ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0) as vfp_PorcDescuentoFormaPago --Obtiene el porcentaje de descuento por forma de pago. --hop_PorcDescuento1
			--,(((fad.fad_Total * vin.[vin_PorcConvenio])/100) * (ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0)))/100 as vfp_MontoDescuentoFormaPago -- Monto de descuento por forma de pago segu  convenio. --hop_MontoDescuento1
			--,CASE WHEN ISNULL(((((fad.fad_Total * vin.[vin_PorcConvenio])/100) * (ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0)))/100), 0) > 0 THEN 'Convenio de Descuento por forma de pago.' ELSE NULL END conceptoDescuento --hop_ConceptoDescuento1
			--,((CASE WHEN sdd.sdd_ResponsableDescuento='ALL' THEN ((fad.fad_Total * vin.[vin_PorcConvenio])/100) ELSE
			--	CASE WHEN sdd.sdd_ResponsableDescuento='UNI' THEN ((fad.fad_Subtotal * vin.[vin_PorcConvenio])/100) ELSE
			--	CASE WHEN sdd.sdd_ResponsableDescuento='PME' THEN (fad.fad_Total - (((fad.fad_Subtotal * (100 - vin.[vin_PorcConvenio]))/100))) ELSE ((fad.fad_Total * vin.[vin_PorcConvenio])/100) END END END) * (ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0)))/100 as vfp_MontoDescuentoFormaPago -- Monto de descuento por forma de pago segu  convenio. --hop_MontoDescuento1
			,((CASE WHEN ser.ser_FullHonorarioProfesional=1 THEN fad.fad_Total ELSE CASE WHEN sdd.sdd_ResponsableDescuento='ALL' THEN ((fad.fad_Total * vin.[vin_PorcConvenio])/100) ELSE
				CASE WHEN sdd.sdd_ResponsableDescuento='UNI' THEN ((fad.fad_Subtotal * vin.[vin_PorcConvenio])/100) ELSE
				CASE WHEN sdd.sdd_ResponsableDescuento='PME' THEN (fad.fad_Total - (((fad.fad_Subtotal * (100 - vin.[vin_PorcConvenio]))/100))) ELSE ((fad.fad_Total * vin.[vin_PorcConvenio])/100) END END END END) * (ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0)))/100 as vfp_MontoDescuentoFormaPago -- Monto de descuento por forma de pago segu  convenio. --hop_MontoDescuento1


			,CASE WHEN ISNULL((((CASE WHEN sdd.sdd_ResponsableDescuento='ALL' THEN ((fad.fad_Total * vin.[vin_PorcConvenio])/100) ELSE
				CASE WHEN sdd.sdd_ResponsableDescuento='UNI' THEN ((fad.fad_Subtotal * vin.[vin_PorcConvenio])/100) ELSE
				CASE WHEN sdd.sdd_ResponsableDescuento='PME' THEN (fad.fad_Total - (((fad.fad_Subtotal * (100 - vin.[vin_PorcConvenio]))/100))) ELSE ((fad.fad_Total * vin.[vin_PorcConvenio])/100) END END END) * (ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0)))/100), 0) > 0 THEN 'Convenio de Descuento por forma de pago.' ELSE NULL END conceptoDescuento --hop_ConceptoDescuento1


			,0 --hop_PorcDescuento2
			,0 --hop_MontoDescuento2
			,NULL --hop_ConceptoDescuento2

			--,((fad.fad_Total * vin.[vin_PorcConvenio])/100) - ((((fad.fad_Total * vin.[vin_PorcConvenio])/100) * (ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0)))/100) as hod_MontoConvenioConDescFormaPago
			--,CASE WHEN sdd.sdd_ResponsableDescuento='PME' THEN (((fad.fad_Total * vin.[vin_PorcConvenio])/100) - ((((fad.fad_Total * vin.[vin_PorcConvenio])/100) * (ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0)))/100)) - sdd.sdd_MontoDescuento ELSE (((fad.fad_Total * vin.[vin_PorcConvenio])/100) - ((((fad.fad_Total * vin.[vin_PorcConvenio])/100) * (ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0)))/100)) END as hod_MontoConvenioConDescFormaPagoYDescuentoAVoluntad --hop_Total
			--,(CASE WHEN sdd.sdd_ResponsableDescuento='ALL' THEN ((fad.fad_Total * vin.[vin_PorcConvenio])/100) ELSE
			--	CASE WHEN sdd.sdd_ResponsableDescuento='UNI' THEN ((fad.fad_Subtotal * vin.[vin_PorcConvenio])/100) ELSE
			--	CASE WHEN sdd.sdd_ResponsableDescuento='PME' THEN (fad.fad_Total - (((fad.fad_Subtotal * (100 - vin.[vin_PorcConvenio]))/100))) ELSE ((fad.fad_Total * vin.[vin_PorcConvenio])/100) END END END) - (((CASE WHEN sdd.sdd_ResponsableDescuento='ALL' THEN ((fad.fad_Total * vin.[vin_PorcConvenio])/100) ELSE
			--	CASE WHEN sdd.sdd_ResponsableDescuento='UNI' THEN ((fad.fad_Subtotal * vin.[vin_PorcConvenio])/100) ELSE
			--	CASE WHEN sdd.sdd_ResponsableDescuento='PME' THEN (fad.fad_Total - (((fad.fad_Subtotal * (100 - vin.[vin_PorcConvenio]))/100))) ELSE ((fad.fad_Total * vin.[vin_PorcConvenio])/100) END END END) * (ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0)))/100) as hod_MontoConvenioConDescFormaPagoYDescuentoAVoluntad --hop_Total
			,(CASE WHEN ser.ser_FullHonorarioProfesional=1 THEN fad.fad_Total ELSE CASE WHEN sdd.sdd_ResponsableDescuento='ALL' THEN ((fad.fad_Total * vin.[vin_PorcConvenio])/100) ELSE
				CASE WHEN sdd.sdd_ResponsableDescuento='UNI' THEN ((fad.fad_Subtotal * vin.[vin_PorcConvenio])/100) ELSE
				CASE WHEN sdd.sdd_ResponsableDescuento='PME' THEN (fad.fad_Total - (((fad.fad_Subtotal * (100 - vin.[vin_PorcConvenio]))/100))) ELSE ((fad.fad_Total * vin.[vin_PorcConvenio])/100) END END END END) - (((CASE WHEN ser.ser_FullHonorarioProfesional=1 THEN fad.fad_Total ELSE CASE WHEN sdd.sdd_ResponsableDescuento='ALL' THEN ((fad.fad_Total * vin.[vin_PorcConvenio])/100) ELSE
				CASE WHEN sdd.sdd_ResponsableDescuento='UNI' THEN ((fad.fad_Subtotal * vin.[vin_PorcConvenio])/100) ELSE
				CASE WHEN sdd.sdd_ResponsableDescuento='PME' THEN (fad.fad_Total - (((fad.fad_Subtotal * (100 - vin.[vin_PorcConvenio]))/100))) ELSE ((fad.fad_Total * vin.[vin_PorcConvenio])/100) END END END END) * (ISNULL((select top 1 [vfp_PorcDescuento] from unidadservicio.vfp_VinculacionFormaPago vfp where vfp.[vin_Id]=vin.vin_Id and [fpa_Id]=(select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0 order by [pfa_Monto] desc) and [vfp_Estatus]=1 and [vfp_Eliminado]=0), 0)))/100) as hod_MontoConvenioConDescFormaPagoYDescuentoAVoluntad --hop_Total

			,NULL --hop_Descripcion

			,GETDATE()
			,@usuario
			,0
			,NULL
			,NULL
		FROM  [factura].[fac_Factura] fac INNER JOIN [gestion].[con_Consulta] con
			ON con.con_Id=fac.con_Id INNER JOIN [gestion].[sdi_ServicioDiagnostico] sdi
			ON con.[con_Id]=sdi.con_Id INNER JOIN [gestion].[sdd_ServicioDiagnosticoDetalle] sdd
			ON sdi.[sdi_Id]=sdd.[sdi_Id] INNER JOIN [factura].[fad_FacturaDetalle] fad
			ON fac.fac_Id=fad.fac_Id AND sdd.sdd_Id=fad.sdd_Id INNER JOIN [unidadservicio].[vin_Vinculacion] vin
			ON vin.[vin_Id]=sdd.[vin_Id] INNER JOIN [profesionalmedico].[pme_ProfesionalMedico] pme
			ON pme.pme_Id=vin.pme_Id INNER JOIN [suscripcion].[dsu_DetalleSuscripcion] dsuPme
			ON dsuPme.dsu_Id=pme.dsu_Id INNER JOIN [factura].[doc_Documento] doc
			ON doc.fac_Id=fac.fac_Id INNER JOIN [unidadservicio].[pio_Precio] pio
			ON pio.pio_Id=sdd.pio_Id INNER JOIN [unidadservicio].[ser_Servicio] ser
			ON ser.ser_Id=pio.[ser_Id] INNER JOIN [unidadservicio].[cat_Categoria] cat
			ON cat.cat_Id=ser.cat_Id
		WHERE sdi.sdi_Eliminado=0
			AND sdd.sdd_Eliminado=0
			AND fac.fac_Eliminado=0
			AND fad.fad_Eliminado=0
			AND con.con_Eliminado=0
			AND fac.gca_Id is not null
			AND doc.doc_Eliminado=0
			--AND doc.doc_Finalizado=1
			--AND MONTH(fac.fac_Fecha)=@hon_Month
			--AND YEAR(fac.fac_Fecha)=@hon_Year
			AND vin.vin_Id=@vinId
			AND fac.uni_Id=@uniId
			AND fad.fad_Id=@fadId
			AND cat.cat_CodigoImport NOT IN('AC')
			--AND (select top 1 [fpa_Id] from [factura].[pfa_PagosFactura] pfa where pfa.[fac_Id]=fac.fac_Id and [pfa_Eliminado]=0) is not null
			

			SELECT 'OK' AS Id

END

GO

GRANT  EXECUTE ON honorario.pi_hop_HonorarioProfesional TO PUBLIC

GO

/*

select * from [honorario].hop_HonorarioProfesional


*/


/*====================================================================================================
5.2. CREAR SP ps_hop_HonorarioProfesionalConfirmadosPorFacId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_hop_HonorarioProfesionalConfirmadosPorFacId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_hop_HonorarioProfesionalConfirmadosPorFacId TO PUBLIC
	DROP PROCEDURE honorario.ps_hop_HonorarioProfesionalConfirmadosPorFacId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

-- exec [honorario].[ps_hop_HonorarioProfesionalConfirmadosPorFacId] 'f9c39cf8-bbb8-4374-a4e6-7f569c425229'

CREATE PROCEDURE [honorario].[ps_hop_HonorarioProfesionalConfirmadosPorFacId]
@facId uniqueidentifier
,@vinId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
	SELECT 
	
	(SELECT 
		count(fad.fad_Id)
	FROM [factura].[fad_FacturaDetalle] fad INNER JOIN [unidadservicio].[pio_Precio] pio
		ON fad.pio_Id=pio.pio_Id INNER JOIN [unidadservicio].[ser_Servicio] ser
		ON ser.ser_Id=pio.ser_Id INNER JOIN [unidadservicio].[cat_Categoria] cat
		ON cat.cat_Id=ser.cat_Id INNER JOIN [gestion].[sdd_ServicioDiagnosticoDetalle] sdd
		ON sdd.sdd_Id=fad.sdd_Id
	WHERE fad.fad_Eliminado=0
	AND sdd.sdd_Eliminado=0
	AND cat.cat_CodigoImport NOT IN('AC')
		and fad.fac_Id=@facId
		and sdd.vin_Id=@vinId
		)

		- 

	(SELECT 
		count(fad.fad_Id)
	FROM [honorario].hop_HonorarioProfesional hop INNER JOIN [factura].[fad_FacturaDetalle] fad
		on hop.fad_Id=fad.fad_Id INNER JOIN [unidadservicio].[pio_Precio] pio
		ON fad.pio_Id=pio.pio_Id INNER JOIN [unidadservicio].[ser_Servicio] ser
		ON ser.ser_Id=pio.ser_Id INNER JOIN [unidadservicio].[cat_Categoria] cat
		ON cat.cat_Id=ser.cat_Id INNER JOIN [gestion].[sdd_ServicioDiagnosticoDetalle] sdd
		ON sdd.sdd_Id=fad.sdd_Id
	WHERE fad.fad_Eliminado=0
	AND sdd.sdd_Eliminado=0
		and hop.hop_Eliminado=0
		AND cat.cat_CodigoImport NOT IN('AC')
		and fad.fac_Id=@facId
		and sdd.vin_Id=@vinId
		)
	as ServiciosPorConfirmar

	-- AND cat.cat_CodigoImport NOT IN('RX', 'AC')


END

GO

GRANT  EXECUTE ON honorario.ps_hop_HonorarioProfesionalConfirmadosPorFacId TO PUBLIC

GO

/*====================================================================================================
5.3. CREAR SP ps_hop_HonorarioProfesionalDashboard
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_hop_HonorarioProfesionalDashboard'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_hop_HonorarioProfesionalDashboard TO PUBLIC
	DROP PROCEDURE honorario.ps_hop_HonorarioProfesionalDashboard
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

-- exec [honorario].[ps_Wfp_WorkflowPagoEstadoActualPorHorId] 4, 2021, '863C4678-B9B2-474E-A913-D1526D7CCBBE', '45d1754a-55c6-46be-9e21-71c1776c5c3e'

CREATE PROCEDURE [honorario].[ps_hop_HonorarioProfesionalDashboard]
@vin_Id uniqueidentifier
,@hon_Month int
,@hon_Year int
AS
BEGIN
	SET NOCOUNT ON

	select 
	
	--Total Honorarios del Profesional
	ISNULL((SELECT SUM(hop.hop_Total) 
	FROM [honorario].hop_HonorarioProfesional hop INNER JOIN [factura].[fad_FacturaDetalle] fad
		on hop.fad_Id=fad.fad_Id INNER JOIN [unidadservicio].[pio_Precio] pio
		ON fad.pio_Id=pio.pio_Id INNER JOIN [unidadservicio].[ser_Servicio] ser
		ON ser.ser_Id=pio.ser_Id INNER JOIN [unidadservicio].[cat_Categoria] cat
		ON cat.cat_Id=ser.cat_Id
	WHERE fad.fad_Eliminado=0
		and hop.hop_Eliminado=0
		AND cat.cat_CodigoImport NOT IN('AC')
		and hop.vin_Id=@vin_Id
		AND hop.hop_Month=@hon_Month
		AND hop.hop_Year=@hon_Year),0) as hon_Saldo
	,

	--Total Honorarios del Profesional
	ISNULL((SELECT SUM(hon.hon_MontoTotal) 
	FROM [honorario].[hon_Honorario] hon
	WHERE hon.hon_Eliminado=0
		AND hon.vin_Id=@vin_Id
		AND hon.hon_Month=@hon_Month
		AND hon.hon_Year=@hon_Year),0) as hon_SaldoValidado

		,

	--Total Honorarios del Profesional
	ISNULL((SELECT SUM(phn.phn_MontoPagado) 
	FROM [honorario].[phn_PagoHonorario] phn
	WHERE phn.phn_Eliminado=0
		AND phn.vin_Id=@vin_Id
		AND phn.phn_Month=@hon_Month
		AND phn.phn_Year=@hon_Year
		AND phn.phn_Pagado=1),0) as hon_MontoPagado
		,
	-->
	--Cantidad de Servicios Honorarios del Profesional
	ISNULL((SELECT COUNT(hop.fad_Id) 
	FROM [honorario].hop_HonorarioProfesional hop INNER JOIN [factura].[fad_FacturaDetalle] fad
		on hop.fad_Id=fad.fad_Id INNER JOIN [unidadservicio].[pio_Precio] pio
		ON fad.pio_Id=pio.pio_Id INNER JOIN [unidadservicio].[ser_Servicio] ser
		ON ser.ser_Id=pio.ser_Id INNER JOIN [unidadservicio].[cat_Categoria] cat
		ON cat.cat_Id=ser.cat_Id
	WHERE fad.fad_Eliminado=0
		and hop.hop_Eliminado=0
		AND cat.cat_CodigoImport NOT IN('AC')
		and hop.vin_Id=@vin_Id
		AND hop.hop_Month=@hon_Month
		AND hop.hop_Year=@hon_Year),0) as hon_CantServicios
		,
	-->
	--Cantidad de Pacientes Honorarios del Profesional
	ISNULL((SELECT COUNT(DISTINCT(fac.pac_Id)) 
	FROM [honorario].hop_HonorarioProfesional hop INNER JOIN [factura].[fad_FacturaDetalle] fad
		on hop.fad_Id=fad.fad_Id INNER JOIN [unidadservicio].[pio_Precio] pio
		ON fad.pio_Id=pio.pio_Id INNER JOIN [unidadservicio].[ser_Servicio] ser
		ON ser.ser_Id=pio.ser_Id INNER JOIN [unidadservicio].[cat_Categoria] cat
		ON cat.cat_Id=ser.cat_Id INNER JOIN [factura].[fac_Factura] fac
		ON fac.fac_Id=fad.fac_Id
	WHERE fad.fad_Eliminado=0
		and hop.hop_Eliminado=0
		AND cat.cat_CodigoImport NOT IN('AC')
		and hop.vin_Id=@vin_Id
		AND hop.hop_Month=@hon_Month
		AND hop.hop_Year=@hon_Year),0) as hon_CantPacientes
		,
	-->
	--Cantidad de Dias Efectivos Honorarios del Profesional
	ISNULL((SELECT COUNT( DISTINCT day(con.con_Fecha)) 
	FROM [honorario].hop_HonorarioProfesional hop INNER JOIN [factura].[fad_FacturaDetalle] fad
		on hop.fad_Id=fad.fad_Id INNER JOIN [unidadservicio].[pio_Precio] pio
		ON fad.pio_Id=pio.pio_Id INNER JOIN [unidadservicio].[ser_Servicio] ser
		ON ser.ser_Id=pio.ser_Id INNER JOIN [unidadservicio].[cat_Categoria] cat
		ON cat.cat_Id=ser.cat_Id INNER JOIN [factura].[fac_Factura] fac
		ON fac.fac_Id=fad.fac_Id INNER JOIN [gestion].[con_Consulta] con
		ON con.con_Id=fac.con_Id
	WHERE fad.fad_Eliminado=0
		and hop.hop_Eliminado=0
		AND cat.cat_CodigoImport NOT IN('AC')
		and hop.vin_Id=@vin_Id
		AND hop.hop_Month=@hon_Month
		AND hop.hop_Year=@hon_Year),0) as hon_CantDiasEfectivos
	-->
	,
	ISNULL((select SUM(hon_Honorario)
	FROM (
	SELECT fad.fad_Total
		,vin.vin_PorcConvenio
		,CASE WHEN ser.ser_FullHonorarioProfesional=1 THEN fad.fad_Total ELSE (fad.fad_Total * vin.vin_PorcConvenio)/100 END hon_Honorario
		,sdd.sdd_Id
	FROM  [gestion].[con_Consulta] con INNER JOIN [gestion].[his_Historia] his
		ON his.his_Id=con.his_Id INNER JOIN [paciente].[pac_Paciente] pac
		ON pac.pac_Id=his.pac_Id INNER JOIN [paciente].[pat_PacienteTitular] pat
		ON pat.pac_Id=pac.pac_Id INNER JOIN [unidadservicio].[sed_Sede] sed
		ON sed.[sed_Id]=con.[sed_Id] INNER JOIN [unidadservicio].[uni_UnidadServicio] uni
		ON uni.uni_Id=sed.uni_Id INNER JOIN [gestion].[sdi_ServicioDiagnostico] sdi
		ON con.[con_Id]=sdi.con_Id INNER JOIN [gestion].[sdd_ServicioDiagnosticoDetalle] sdd
		ON sdi.[sdi_Id]=sdd.[sdi_Id] INNER JOIN [unidadservicio].[dic_Diagnostico] dic
		ON sdi.dic_Id=dic.[dic_Id] INNER JOIN [unidadservicio].[pto_Procedimiento] pto
		ON sdi.pto_Id=pto.pto_Id INNER JOIN [unidadservicio].[pio_Precio] pio
		ON sdd.pio_Id=pio.pio_Id INNER JOIN [factura].[fac_Factura] fac
		ON fac.[sdi_Id]=sdi.sdi_Id INNER JOIN [factura].[fad_FacturaDetalle] fad
		ON fac.fac_Id=fad.fac_Id AND sdd.sdd_Id=fad.sdd_Id INNER JOIN [suscripcion].[dsu_DetalleSuscripcion] dsu
		ON dsu.[dsu_Id]=pat.[dsu_Id] INNER JOIN [suscripcion].[sus_Suscripcion] sus
		ON sus.sus_Id=dsu.sus_Id INNER JOIN [cita].[mcs_MotivoConsultaSimple] mcs
		ON mcs.mcs_Id=con.mcs_Id INNER JOIN [utilitario].[tid_TipoIdentificacion] tidSus
		ON tidSus.[tid_Id]=dsu.[tid_Id] INNER JOIN [unidadservicio].[ser_Servicio] ser
		ON ser.ser_Id=pio.ser_Id INNER JOIN [unidadservicio].[cat_Categoria] cat
		ON cat.cat_Id=ser.cat_Id INNER JOIN [unidadservicio].[vin_Vinculacion] vin
		ON vin.vin_Id=sdd.vin_Id
	WHERE sus.[sus_Eliminado]=0
		AND dsu.dsu_Eliminado=0
		AND sdi.sdi_Eliminado=0
		AND sdd.sdd_Eliminado=0
		AND fac.fac_Eliminado=0
		AND fad.fad_Eliminado=0
		AND con.con_Eliminado=0
		AND cat.cat_CodigoImport NOT IN('AC')
		AND MONTH(con.con_Fecha)=@hon_Month
		AND YEAR(con.con_Fecha)=@hon_Year
		AND sdd.vin_Id=@vin_Id
		AND fad.fad_Id NOT IN(SELECT hop.fad_Id FROM [honorario].hop_HonorarioProfesional hop WHERE hop.hop_Eliminado=0 and hop.vin_Id=@vin_Id)
		) t1),0)  as fad_Total_Honorarios

END

GO

GRANT  EXECUTE ON honorario.ps_hop_HonorarioProfesionalDashboard TO PUBLIC

GO

/*====================================================================================================
5.4. CREAR SP pu_Hod_AjustePorcConvenioPorId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pu_Hod_AjustePorcConvenioPorId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pu_Hod_AjustePorcConvenioPorId TO PUBLIC
	DROP PROCEDURE honorario.pu_Hod_AjustePorcConvenioPorId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[pu_Hod_AjustePorcConvenioPorId]
@hopId uniqueidentifier
,@hopPorcoConvenio MONEY
,@hon_Month int
,@hon_Year int
,@vinId uniqueidentifier
,@uniId uniqueidentifier
,@sedId uniqueidentifier
,@hon_Version int
AS
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #T_TEMP (hop_Id uniqueidentifier, temp_TotalVenta money, temp_PorcDescuento1 money, temp_PorcDescuento2 money, temp_Nuevo_Monto_Honorario money, temp_nuevo_desc1 money, temp_nuevo_desc2 money, temp_nuevo_total money)

	INSERT INTO #T_TEMP
	SELECT hop.hop_Id, hop.hop_TotalVenta, hop.hop_PorcDescuento1, hop.hop_PorcDescuento2, 0, 0, 0, 0
	FROM [honorario].hop_HonorarioProfesional hop
	WHERE hop.hop_Id=@hopId

	UPDATE #T_TEMP
		SET temp_Nuevo_Monto_Honorario= ((temp_TotalVenta * @hopPorcoConvenio)/100)
			,temp_nuevo_desc1= ((((temp_TotalVenta * @hopPorcoConvenio)/100) * temp_PorcDescuento1)/100)
			,temp_nuevo_desc2= ((((temp_TotalVenta * @hopPorcoConvenio)/100) * temp_PorcDescuento2)/100)
		    ,temp_nuevo_total= (((temp_TotalVenta * @hopPorcoConvenio)/100) - ((((temp_TotalVenta * @hopPorcoConvenio)/100) * temp_PorcDescuento1)/100) - ((((temp_TotalVenta * @hopPorcoConvenio)/100) * temp_PorcDescuento2)/100))
	WHERE hop_Id=@hopId

	
	UPDATE hop
		SET hop_PorcConvenio=@hopPorcoConvenio
		,hop_MontoConvenio=temp_Nuevo_Monto_Honorario
		,hop_MontoDescuento1=temp_nuevo_desc1
		,hop_MontoDescuento2=temp_nuevo_desc2
		,[hop_Total]=temp_nuevo_total
	FROM [honorario].hop_HonorarioProfesional hop INNER JOIN #T_TEMP t
		ON t.hop_Id=hop.hop_Id
	WHERE hop.[hop_Id]=@hopId

	DROP TABLE #T_TEMP

	---------------------------------------------------------------------------------------------------------
	--Recalculo
	---------------------------------------------------------------------------------------------------------

	CREATE TABLE #T_TEMP_TOT (sum_hop_MontoConvenio money, sum_hop_MontoDescuento1 money, sum_hop_MontoDescuento2 money)

	INSERT INTO #T_TEMP_TOT
	select SUM(hop_MontoConvenio)
		,SUM(hop_MontoDescuento1)
		,SUM(hop_MontoDescuento2)		
	FROM [honorario].hop_HonorarioProfesional hop
	WHERE isnull(hop.hop_Eliminado,0)=0
		and hop.uni_Id=@uniId
		and hop.sed_Id=@sedId
		AND hop.vin_Id=@vinId
		AND hop.hop_Month=@hon_Month
		and hop.hop_Year=@hon_Year
		and hop.hop_Version=@hon_Version

	
	UPDATE [honorario].hon_Honorario
		SET hon_TotalConvenio=(SELECT sum_hop_MontoConvenio FROM #T_TEMP_TOT)
			, hon_MontoDescuento1= (SELECT sum_hop_MontoDescuento1 FROM #T_TEMP_TOT)
			, hon_MontoDescuento2=(SELECT sum_hop_MontoDescuento2 FROM #T_TEMP_TOT)
			,hon_SubTotalConvenio=((SELECT sum_hop_MontoConvenio FROM #T_TEMP_TOT) - ((SELECT sum_hop_MontoDescuento1 FROM #T_TEMP_TOT) + (SELECT sum_hop_MontoDescuento2 FROM #T_TEMP_TOT) + hon_MontoDescuentoOtros))
			,hon_MontoImpuesto1=((((SELECT sum_hop_MontoConvenio FROM #T_TEMP_TOT) - ((SELECT sum_hop_MontoDescuento1 FROM #T_TEMP_TOT) + (SELECT sum_hop_MontoDescuento2 FROM #T_TEMP_TOT) + hon_MontoDescuentoOtros)) * hon_PorcImpuesto1)/100)
			,hon_MontoTotal=(((SELECT sum_hop_MontoConvenio FROM #T_TEMP_TOT) - ((SELECT sum_hop_MontoDescuento1 FROM #T_TEMP_TOT) + (SELECT sum_hop_MontoDescuento2 FROM #T_TEMP_TOT) + hon_MontoDescuentoOtros)) - ((((SELECT sum_hop_MontoConvenio FROM #T_TEMP_TOT) - ((SELECT sum_hop_MontoDescuento1 FROM #T_TEMP_TOT) + (SELECT sum_hop_MontoDescuento2 FROM #T_TEMP_TOT) + hon_MontoDescuentoOtros)) * hon_PorcImpuesto1)/100))
	WHERE uni_Id=@uniId
		and sed_Id=@sedId
		AND vin_Id=@vinId
		AND hon_Month=@hon_Month
		and hon_Year=@hon_Year
		and hon_Version=@hon_Version

	DROP TABLE #T_TEMP_TOT
	

	select 'OK' Id

END

GO

GRANT  EXECUTE ON honorario.pu_Hod_AjustePorcConvenioPorId TO PUBLIC

GO


/*====================================================================================================
5.4. CREAR SP pd_Hod_HonorarioDetallePorId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pd_Hod_HonorarioDetallePorId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pd_Hod_HonorarioDetallePorId TO PUBLIC
	DROP PROCEDURE honorario.pd_Hod_HonorarioDetallePorId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[pd_Hod_HonorarioDetallePorId]
@hopId uniqueidentifier
,@hon_Month int
,@hon_Year int
,@vinId uniqueidentifier
,@uniId uniqueidentifier
,@sedId uniqueidentifier
,@hon_Version int
,@usuario varchar(50)
AS
BEGIN
	SET NOCOUNT ON

	UPDATE [honorario].hop_HonorarioProfesional
		SET hop_Eliminado=1
			,hop_FechaEliminacion=getdate()
			,hop_UsuarioEliminacion=@usuario
	WHERE [hop_Id]=@hopId

	
	---------------------------------------------------------------------------------------------------------
	--Recalculo
	---------------------------------------------------------------------------------------------------------

	CREATE TABLE #T_TEMP_TOT (sum_hop_MontoConvenio money, sum_hop_MontoDescuento1 money, sum_hop_MontoDescuento2 money)

	INSERT INTO #T_TEMP_TOT
	select SUM(hop_MontoConvenio)
		,SUM(hop_MontoDescuento1)
		,SUM(hop_MontoDescuento2)		
	FROM [honorario].hop_HonorarioProfesional hop
	WHERE isnull(hop.hop_Eliminado,0)=0
		and hop.uni_Id=@uniId
		and hop.sed_Id=@sedId
		AND hop.vin_Id=@vinId
		AND hop.hop_Month=@hon_Month
		and hop.hop_Year=@hon_Year
		and hop.hop_Version=@hon_Version

	
	UPDATE [honorario].hon_Honorario
		SET hon_TotalConvenio=(SELECT sum_hop_MontoConvenio FROM #T_TEMP_TOT)
			, hon_MontoDescuento1= (SELECT sum_hop_MontoDescuento1 FROM #T_TEMP_TOT)
			, hon_MontoDescuento2=(SELECT sum_hop_MontoDescuento2 FROM #T_TEMP_TOT)
			,hon_SubTotalConvenio=((SELECT sum_hop_MontoConvenio FROM #T_TEMP_TOT) - ((SELECT sum_hop_MontoDescuento1 FROM #T_TEMP_TOT) + (SELECT sum_hop_MontoDescuento2 FROM #T_TEMP_TOT) + hon_MontoDescuentoOtros))
			,hon_MontoImpuesto1=((((SELECT sum_hop_MontoConvenio FROM #T_TEMP_TOT) - ((SELECT sum_hop_MontoDescuento1 FROM #T_TEMP_TOT) + (SELECT sum_hop_MontoDescuento2 FROM #T_TEMP_TOT) + hon_MontoDescuentoOtros)) * hon_PorcImpuesto1)/100)
			,hon_MontoTotal=(((SELECT sum_hop_MontoConvenio FROM #T_TEMP_TOT) - ((SELECT sum_hop_MontoDescuento1 FROM #T_TEMP_TOT) + (SELECT sum_hop_MontoDescuento2 FROM #T_TEMP_TOT) + hon_MontoDescuentoOtros)) - ((((SELECT sum_hop_MontoConvenio FROM #T_TEMP_TOT) - ((SELECT sum_hop_MontoDescuento1 FROM #T_TEMP_TOT) + (SELECT sum_hop_MontoDescuento2 FROM #T_TEMP_TOT) + hon_MontoDescuentoOtros)) * hon_PorcImpuesto1)/100))
	WHERE uni_Id=@uniId
		and sed_Id=@sedId
		AND vin_Id=@vinId
		AND hon_Month=@hon_Month
		and hon_Year=@hon_Year
		and hon_Version=@hon_Version

	DROP TABLE #T_TEMP_TOT
	

	select 'OK' Id

END

GO

GRANT  EXECUTE ON honorario.pd_Hod_HonorarioDetallePorId TO PUBLIC

GO

/*====================================================================================================
5.5. CREAR SP pd_Hop_HonorarioProfesionalPorFadId
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pd_Hop_HonorarioProfesionalPorFadId'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pd_Hop_HonorarioProfesionalPorFadId TO PUBLIC
	DROP PROCEDURE honorario.pd_Hop_HonorarioProfesionalPorFadId
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[pd_Hop_HonorarioProfesionalPorFadId]
@vinId uniqueidentifier
,@usuario varchar(50)
,@fadId uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON

	UPDATE [honorario].hop_HonorarioProfesional
		SET hop_Eliminado=1
			,hop_FechaEliminacion=getdate()
			,hop_UsuarioEliminacion=@usuario
	WHERE [fad_Id]=@fadId and vin_Id=@vinId
	

	select 'OK' Id

END

GO

GRANT  EXECUTE ON honorario.pd_Hop_HonorarioProfesionalPorFadId TO PUBLIC

GO

/*====================================================================================================
------------------------------------------------------------------------------------------------------
6- PAGO DE HONORARIOS - ADJUNTAR BOLETA DEL PROFESIONAL
------------------------------------------------------------------------------------------------------
=====================================================================================================*/

/*====================================================================================================
6.1. CREAR SP pu_phn_PagoHonorarioAdjuntarBoleta
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='pu_phn_PagoHonorarioAdjuntarBoleta'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.pu_phn_PagoHonorarioAdjuntarBoleta TO PUBLIC
	DROP PROCEDURE honorario.pu_phn_PagoHonorarioAdjuntarBoleta
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[pu_phn_PagoHonorarioAdjuntarBoleta]
@phn_Id uniqueidentifier

,@phn_Nombre varchar(50)
,@phn_Extension varchar(10)
,@phn_Imagen [varbinary](max)

,@usuario varchar(50)
AS
BEGIN
	SET NOCOUNT ON
	
	UPDATE [honorario].phn_PagoHonorario
		SET phn_ImagenName=@phn_Nombre
			,phn_ImagenContentType=@phn_Extension
			,phn_Imagen=@phn_Imagen
	WHERE phn_Id=@phn_Id

	select 'OK' AS Id

END

GO

GRANT  EXECUTE ON honorario.pu_phn_PagoHonorarioAdjuntarBoleta TO PUBLIC

GO

/*====================================================================================================
6.2. CREAR SP ps_phn_VerBoletaAdjunta
=====================================================================================================*/

IF exists (SELECT name
           FROM sysobjects
           WHERE name='ps_phn_VerBoletaAdjunta'
             AND uid=(select schema_id from sys.schemas where name = 'honorario')
             AND TYPE='P')
BEGIN
	REVOKE  EXECUTE ON honorario.ps_phn_VerBoletaAdjunta TO PUBLIC
	DROP PROCEDURE honorario.ps_phn_VerBoletaAdjunta
END

GO

/*=============================================
	CREATED by Saumir Navarro, on 02/10/2018
	Description:	<Insertar datos .>
=============================================*/

CREATE PROCEDURE [honorario].[ps_phn_VerBoletaAdjunta]
@phn_Id uniqueidentifier
AS
BEGIN
	SET NOCOUNT ON
	
	select phn.phn_ImagenName
		,phn.phn_ImagenContentType
		,phn.phn_Imagen
	from [honorario].phn_PagoHonorario phn
	where phn.phn_Id=@phn_Id

END

GO

GRANT  EXECUTE ON honorario.ps_phn_VerBoletaAdjunta TO PUBLIC

GO

/*====================================================================================================
7. FIN DE LA TRANSACCION
=====================================================================================================*/
-- ROLLBACK /*en caso de que la muestra de datos despues del cambio no coincida con los resultados. */
-- COMMIT   /*cuando la muestra de datos despues del cambio coincide con los resultados. */