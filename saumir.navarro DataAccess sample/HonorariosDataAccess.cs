using CSaludObject.BusinessObjects;
using CSaludObject.Objects;
using CSaludObject.Utilities;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CSaludDataAccess.BusinessDataAccess
{
    public class HonorariosDataAccess: AccessDataConnections.Entity
    {
        #region Constructor
        public HonorariosDataAccess()
            : base("CnnCSaludDB")
        {
            base.OpenConnection();
        }
        public HonorariosDataAccess(SqlConnection objSQLConnection)
            : base(objSQLConnection)
        {
        }
        #endregion

        #region Honorarios

        public List<esq_BOB_HonorarioPorSede> GetHonorariosTotalesPorUniId(int honMonth, int honYear, string uniId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_HonorariosTotalesPorUniId",
                    new string[] { "@hon_Month", "@hon_Year", "@uniId" },
                    new object[] { honMonth, honYear, uniId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioPorSede> listado = new List<esq_BOB_HonorarioPorSede>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioPorSede obj = new esq_BOB_HonorarioPorSede();
                    {
                        obj.UnidadServicio = dr["uni_NombreLegal"].ToString();
                        obj.Sede = dr["sed_Nombre"].ToString();
                        obj.TotalVentasServicios = decimal.Parse(dr["hon_SubTotalVenta"].ToString());
                        obj.TotalHonorarios = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorarioRankingVentasPorSede> GetHonorariosRankingPorUniId(int honMonth, int honYear, string uniId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_HonorariosRankingPorUniId",
                    new string[] { "@hon_Month", "@hon_Year", "@uniId" },
                    new object[] { honMonth, honYear, uniId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioRankingVentasPorSede> listado = new List<esq_BOB_HonorarioRankingVentasPorSede>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioRankingVentasPorSede obj = new esq_BOB_HonorarioRankingVentasPorSede();
                    {
                        obj.Profesional = dr["fullNamePme"].ToString();
                        obj.TotalServicios = decimal.Parse(dr["hon_MontoTotal"].ToString());
                        
                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorarioProfesionalSinVentas> GetProfesionalesSinHonorariosPorUniId(int honMonth, int honYear, string uniId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_ProfesionalesSinHonorariosPorUniId",
                    new string[] { "@hon_Month", "@hon_Year", "@uniId" },
                    new object[] { honMonth, honYear, uniId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioProfesionalSinVentas> listado = new List<esq_BOB_HonorarioProfesionalSinVentas>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioProfesionalSinVentas obj = new esq_BOB_HonorarioProfesionalSinVentas();
                    {
                        obj.Profesional = dr["fullNamePme"].ToString();
                        

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorarioConsolidado> GetHonorariosProfesionalesPorUniId(int honMonth, int honYear, string uniId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_HonorariosProfesionalesPorUniId",
                    new string[] { "@hon_Month", "@hon_Year", "@uniId" },
                    new object[] { honMonth, honYear, uniId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioConsolidado> listado = new List<esq_BOB_HonorarioConsolidado>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioConsolidado obj = new esq_BOB_HonorarioConsolidado();
                    {
                        obj.vinId = dr["vin_Id"].ToString();
                        obj.Profesional = dr["fullNamePme"].ToString();
                        obj.PorcentajeConvenio = decimal.Parse(dr["vin_PorcConvenio"].ToString()).ToString("N0");
                        obj.TotalServicios = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        obj.ListSede = GetHonorariosProfesionalesPorUniId(honMonth, honYear, uniId, obj.vinId);
                        obj.ObjWfp= GetWorkFlowEstadoPago(honMonth, honYear, uniId, obj.vinId);

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorarioConsolidado> GetHonorariosProfesionalesPorVinId(int honMonth, int honYear, string vinId, string uniId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_HonorariosProfesionalesPorVinId",
                    new string[] { "@hon_Month", "@hon_Year", "@vinId", "@uniId" },
                    new object[] { honMonth, honYear, vinId, uniId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioConsolidado> listado = new List<esq_BOB_HonorarioConsolidado>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioConsolidado obj = new esq_BOB_HonorarioConsolidado();
                    {
                        obj.vinId = dr["vin_Id"].ToString();
                        obj.honId = dr["hon_Id"].ToString();
                        obj.Profesional = dr["fullNamePme"].ToString();
                        obj.PorcentajeConvenio = decimal.Parse(dr["vin_PorcConvenio"].ToString()).ToString("N0");
                        obj.TotalServicios = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        obj.phn_PorAdjuntarBoleta = int.Parse(dr["phn_PorAdjuntarBoleta"].ToString());
                        obj.phn_PorPagado = int.Parse(dr["phn_PorPagado"].ToString());
                        obj.phn_Pagado = int.Parse(dr["phn_Pagado"].ToString());

                        obj.hon_Version = int.Parse(dr["hon_Version"].ToString());


                        obj.phn_Id = dr["phn_Id"].ToString();                       

                        obj.ListSede = GetHonorariosProfesionalesPorUniId(honMonth, honYear, uniId, obj.vinId);
                        //obj.ObjWfp = GetWorkFlowEstadoPago(honMonth, honYear, uniId, obj.vinId);

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        private List<esq_BOB_HonorarioPorSedePorProfesional> GetHonorariosProfesionalesPorUniId(int honMonth, int honYear, string uniId, string vinId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_HonorariosProfesionalesDetallePorSedId",
                    new string[] { "@hon_Month", "@hon_Year", "@uniId", "@vinId" },
                    new object[] { honMonth, honYear, uniId, vinId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioPorSedePorProfesional> listado = new List<esq_BOB_HonorarioPorSedePorProfesional>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioPorSedePorProfesional obj = new esq_BOB_HonorarioPorSedePorProfesional();
                    {
                        obj.Sede = dr["sed_Nombre"].ToString();
                        obj.TotalServicios = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public AResult SetProcesarHonorarios(string iMonth, string iYear, string uniId, string usuario)
        {
            AResult are = new AResult();
            are.Name = "SetProcesarHonorarios";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pg_Hon_GestionarHonorarios",
                    new string[] { "@hon_Month", "@hon_Year", "@uni_Id", "@Usuario" },
                    new object[] { iMonth, iYear, uniId, usuario }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public AResult SetReCalculoHonorarios(string iMonth, string iYear, string vinId, string uniId)
        {
            AResult are = new AResult();
            are.Name = "SetReCalculoHonorarios";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_RecalculoPorMesPorVinId",
                    new string[] { "@hon_Month", "@hon_Year", "@_vinId", "@_uniId" },
                    new object[] { iMonth, iYear, vinId, uniId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public AResult SetDescuentoHonorariosTotales(string honId, decimal honMontoDescuentoOtros, string honConceptoDescuentoOtros, decimal honMontoTotal, string usuario)
        {
            AResult are = new AResult();
            are.Name = "SetDescuentoHonorariosTotales";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pu_Hon_DescuentosOtrosId",
                    new string[] { "@honId", "@honMontoDescuentoOtros", "@honConceptoDescuentoOtros", "@honMontoTotal", "@Usuario" },
                    new object[] { honId, honMontoDescuentoOtros, honConceptoDescuentoOtros, honMontoTotal, usuario }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public AResult SetDescuento1HonorariosDetalle(string hodId, decimal hodPorcDescuento, decimal hodMontoDescuento, string hodConceptoDescuento, string usuario)
        {
            AResult are = new AResult();
            are.Name = "SetDescuentoHonorariosTotales";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pu_Hod_Descuento1PorId",
                    new string[] { "@hodId", "@hodPorcoDescuento", "@hodMontoDescuento", "@hodConceptoDescuento", "@Usuario" },
                    new object[] { hodId, hodPorcDescuento, hodMontoDescuento, hodConceptoDescuento, usuario }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public AResult SetCambioPorcConvenioHonorarioDetalle(string hopId, decimal porcConvenioNuevo, int hon_Month, int hon_Year, string vinId,  string uniId, string sedId, int hon_Version)
        {
            AResult are = new AResult();
            are.Name = "SetDescuentoHonorariosTotales";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pu_Hod_AjustePorcConvenioPorId",
                    new string[] { "@hopId", "@hopPorcoConvenio", "@hon_Month", "@hon_Year", "@vinId", "@uniId", "@sedId", "@hon_Version" },
                    new object[] { hopId, porcConvenioNuevo, hon_Month, hon_Year , vinId, uniId, sedId, hon_Version }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public AResult DeleteHonorarioDetalle(string hopId, int hon_Month, int hon_Year, string vinId, string uniId, string sedId, int hon_Version, string usuario)
        {
            AResult are = new AResult();
            are.Name = "DeleteHonorarioDetalle";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pd_Hod_HonorarioDetallePorId",
                    new string[] { "@hopId", "@hon_Month", "@hon_Year", "@vinId", "@uniId", "@sedId", "@hon_Version", "@usuario" },
                    new object[] { hopId, hon_Month, hon_Year, vinId, uniId, sedId, hon_Version, usuario }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        #endregion

        #region Honorarios Nuevo

        public bool GetValidaCierreHonorariosPorVinId(int honMonth, int honYear, string uniId, string vinId)
        {
            bool cierreExiste = false;
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_ValidarCerrarPeriodoSolicitarPago",
                    new string[] { "@hon_Month", "@hon_Year", "@uni_Id", "@vin_Id" },
                    new object[] { honMonth, honYear, uniId, vinId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                int valor = int.Parse(dt.Rows[0]["cant"].ToString());

                if (valor > 0)
                {
                    cierreExiste = true;
                }
                else
                {
                    cierreExiste = false;
                }

                //-->Fin Cargar los datos a Objeto

                return cierreExiste;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return false;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        

        public AResult SetProcesarCierreHonorarios(string iMonth, string iYear, string uniId, string vinId, string cbcId, string usuario)
        {
            AResult are = new AResult();
            are.Name = "SetProcesarCierreHonorarios";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pi_Hon_CerrarPeriodoSolicitarPago",
                    new string[] { "@hon_Month", "@hon_Year", "@uni_Id", "@vin_Id", "@cbc_Id", "@Usuario" },
                    new object[] { iMonth, iYear, uniId, vinId, cbcId, usuario }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public List<hon_BOB_HonorarioPorSedePendiente> GetListCierreHonorariosPorVinIdPendiente(string uniId, string vinId)
        {
            List<hon_BOB_HonorarioPorSedePendiente> listado = new List<hon_BOB_HonorarioPorSedePendiente>();
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_PendienteCierresSolicitarPagoPoVinId",
                    new string[] { "@uni_Id", "@vin_Id" },
                    new object[] { uniId, vinId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                foreach (DataRow dr in dt.Rows)
                {
                    hon_BOB_HonorarioPorSedePendiente obj = new hon_BOB_HonorarioPorSedePendiente();
                    {
                        obj.uniId = dr["uni_Id"].ToString();

                        string honId= dr["hon_Id"].ToString();

                        
                        if (honId !=null && honId !="")
                        {
                            int _hon_Version = int.Parse(dr["hon_Version"].ToString());
                            obj.Periodo = dr["hop_Month"].ToString() + "-" + dr["hop_Year"].ToString() + " Nro. Solicitud " + _hon_Version.ToString();
                            obj.hon_Version = _hon_Version;
                        }
                        else
                        {
                            obj.Periodo = dr["hop_Month"].ToString() + "-" + dr["hop_Year"].ToString();
                            obj.hon_Version = 0;
                        }

                        obj.monthSelected = dr["hop_Month"].ToString();
                        obj.yearSelected= dr["hop_Year"].ToString();

                        obj.hon_Estado = dr["hon_Estado"].ToString();
                        obj.hon_StrEstado = dr["hon_StrEstado"].ToString();

                        obj.hop_SubtotalVenta = decimal.Parse(dr["hop_SubtotalVenta"].ToString());
                        obj.hop_MontoDescuentoAVoluntad = decimal.Parse(dr["hop_MontoDescuentoAVoluntad"].ToString());
                        obj.hop_TotalVenta = decimal.Parse(dr["hop_TotalVenta"].ToString());
                        obj.hop_PorcConvenio = dr["hop_PorcConvenio"].ToString();
                        obj.hop_MontoConvenio = decimal.Parse(dr["hop_MontoConvenio"].ToString());
                        obj.hop_MontoDescuento1 = decimal.Parse(dr["hop_MontoDescuento1"].ToString());
                        obj.hop_Total = decimal.Parse(dr["hop_Total"].ToString());

                        obj.hon_PorcImpuesto1 = decimal.Parse(dr["hon_PorcImpuesto1"].ToString());
                        obj.hon_MontoImpuesto1 = decimal.Parse(dr["hon_MontoImpuesto1"].ToString());
                        obj.hon_ConceptoImpuesto1 = dr["hon_ConceptoImpuesto1"].ToString();

                        obj.hon_MontoTotal = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<hon_BOB_HonorarioPendienteBoleta> GetListPendienteBoletasPorVinId(string uniId, string vinId)
        {
            List<hon_BOB_HonorarioPendienteBoleta> listado = new List<hon_BOB_HonorarioPendienteBoleta>();
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_PendienteBoletaPorVinId",
                    new string[] { "@uni_Id", "@vin_Id" },
                    new object[] { uniId, vinId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                foreach (DataRow dr in dt.Rows)
                {
                    hon_BOB_HonorarioPendienteBoleta obj = new hon_BOB_HonorarioPendienteBoleta();
                    {
                        obj.phn_Id = dr["phn_Id"].ToString();
                        obj.uni_Id = dr["uni_Id"].ToString();
                        obj.vin_Id = dr["vin_Id"].ToString();
                        obj.cbc_Id = dr["cbc_Id"].ToString();

                        int _hon_Version = int.Parse(dr["phn_Version"].ToString());
                        obj.Periodo = dr["hon_Month"].ToString() + "-" + dr["hon_Year"].ToString() + " Nro. Solicitud " + _hon_Version.ToString();
                                               

                        //obj.Periodo = dr["hon_Month"].ToString()  + "-" + dr["hon_Year"].ToString();
                        obj.phn_Version = _hon_Version;
                        obj.hon_TotalConvenio = decimal.Parse(dr["hon_TotalConvenio"].ToString());
                        obj.hon_MontoDescuento1 = decimal.Parse(dr["hon_MontoDescuento1"].ToString());
                        obj.hon_MontoDescuentoOtros = decimal.Parse(dr["hon_MontoDescuentoOtros"].ToString());
                        obj.hon_SubTotalConvenio = decimal.Parse(dr["hon_SubTotalConvenio"].ToString());
                        obj.hon_PorcImpuesto1 = decimal.Parse(dr["hon_PorcImpuesto1"].ToString());
                        obj.hon_MontoImpuesto1 = decimal.Parse(dr["hon_MontoImpuesto1"].ToString());
                        obj.hon_MontoTotal = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        obj.listDetalle = new List<hon_BOB_HonorarioPendienteBoletaDetalle>();
                        obj.listDetalle = GetListPendienteBoletasDetallePorVinId(obj.phn_Id);

                        string strBoletaEmitida = dr["hon_BoletaEmitida"].ToString();
                        if (strBoletaEmitida=="0")
                        {
                            obj.HonBoletaEmitida = false;
                        }
                        else
                        {
                            obj.HonBoletaEmitida = true;
                        }

                        obj.phn_Pagado = bool.Parse(dr["phn_Pagado"].ToString());
                        obj.phn_ComentarioUni = dr["phn_ComentarioUni"].ToString();
                        obj.phn_DescripcionPago = dr["phn_DescripcionPago"].ToString();

                        obj.monthSelected = dr["hon_Month"].ToString();
                        obj.yearSelected = dr["hon_Year"].ToString();


                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        private List<hon_BOB_HonorarioPendienteBoletaDetalle> GetListPendienteBoletasDetallePorVinId(string phn_Id)
        {
            List<hon_BOB_HonorarioPendienteBoletaDetalle> listado = new List<hon_BOB_HonorarioPendienteBoletaDetalle>();
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_PendienteBoletaDetallePorVinId",
                    new string[] { "@phn_Id" },
                    new object[] { phn_Id }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                foreach (DataRow dr in dt.Rows)
                {
                    hon_BOB_HonorarioPendienteBoletaDetalle obj = new hon_BOB_HonorarioPendienteBoletaDetalle();
                    {
                        obj.sed_Id = dr["sed_Id"].ToString();
                        obj.sed_Nombre = dr["sed_Nombre"].ToString();
                        
                        obj.hon_TotalConvenio = decimal.Parse(dr["hon_TotalConvenio"].ToString());
                        obj.hon_MontoDescuento1 = decimal.Parse(dr["hon_MontoDescuento1"].ToString());
                        obj.hon_MontoDescuentoOtros = decimal.Parse(dr["hon_MontoDescuentoOtros"].ToString());
                        obj.hon_SubTotalConvenio = decimal.Parse(dr["hon_SubTotalConvenio"].ToString());
                        obj.hon_PorcImpuesto1 = decimal.Parse(dr["hon_PorcImpuesto1"].ToString());
                        obj.hon_MontoImpuesto1 = decimal.Parse(dr["hon_MontoImpuesto1"].ToString());
                        obj.hon_MontoTotal = decimal.Parse(dr["hon_MontoTotal"].ToString());


                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }


        #endregion

        #region Honorarios Detalle

        public List<esq_BOB_HonorariosHeader> GetHeaderHonorariosPorVinId(int honMonth, int honYear, string vinId, string uniId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_HeaderHonorariosPorVinId",
                    new string[] { "@hon_Month", "@hon_Year", "@vinId", "@uniId" },
                    new object[] { honMonth, honYear, vinId, uniId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorariosHeader> listado = new List<esq_BOB_HonorariosHeader>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorariosHeader obj = new esq_BOB_HonorariosHeader();
                    {
                        obj.hon_Id = dr["hon_Id"].ToString();
                        obj.uni_Id = dr["uni_Id"].ToString();
                        obj.sed_Id = dr["sed_Id"].ToString();
                        obj.sed_Nombre = dr["sed_Nombre"].ToString();
                        obj.vin_Id = dr["vin_Id"].ToString();
                        obj.hon_Month = int.Parse(dr["hon_Month"].ToString());
                        obj.hon_Year = int.Parse(dr["hon_Year"].ToString());
                        obj.hon_Version = int.Parse(dr["hon_Version"].ToString());
                        obj.hon_CantidadDetalle = int.Parse(dr["hon_CantidadDetalle"].ToString());

                        obj.hon_MontoVenta = decimal.Parse(dr["hon_MontoVenta"].ToString());
                        obj.hon_TotalDescuento = decimal.Parse(dr["hon_TotalDescuento"].ToString());
                        obj.hon_SubTotalVenta = decimal.Parse(dr["hon_SubTotalVenta"].ToString());
                        obj.hon_TotalConvenio = decimal.Parse(dr["hon_TotalConvenio"].ToString());
                        obj.hon_MontoDescuento1 = decimal.Parse(dr["hon_MontoDescuento1"].ToString());
                        obj.hon_MontoDescuento2 = decimal.Parse(dr["hon_MontoDescuento2"].ToString());
                        obj.hon_MontoDescuentoOtros = decimal.Parse(dr["hon_MontoDescuentoOtros"].ToString());
                        obj.hon_ConceptoDescuentoOtros = dr["hon_ConceptoDescuentoOtros"].ToString();
                        obj.hon_SubTotalConvenio = decimal.Parse(dr["hon_SubTotalConvenio"].ToString());

                        obj.hon_PorcImpuesto1 = decimal.Parse(dr["hon_PorcImpuesto1"].ToString());
                        obj.hon_MontoImpuesto1 = decimal.Parse(dr["hon_MontoImpuesto1"].ToString());
                        obj.hon_ConceptoImpuesto1 = dr["hon_ConceptoImpuesto1"].ToString();

                        obj.hon_PorcImpuesto2 = decimal.Parse(dr["hon_PorcImpuesto2"].ToString());
                        obj.hon_MontoImpuesto2 = decimal.Parse(dr["hon_MontoImpuesto2"].ToString());
                        obj.hon_ConceptoImpuesto2 = dr["hon_ConceptoImpuesto2"].ToString();

                        obj.hon_PorcImpuesto3 = decimal.Parse(dr["hon_PorcImpuesto3"].ToString());
                        obj.hon_MontoImpuesto3 = decimal.Parse(dr["hon_MontoImpuesto3"].ToString());
                        obj.hon_ConceptoImpuesto3 = dr["hon_ConceptoImpuesto3"].ToString();

                        obj.hon_MontoTotal = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorariosHeader> GetHeaderHonorariosVersionPorVinId(int honMonth, int honYear, string vinId, string uniId, string hon_Version)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_HeaderHonorariosVersionPorVinId",
                    new string[] { "@hon_Month", "@hon_Year", "@vinId", "@uniId", "@hon_Version" },
                    new object[] { honMonth, honYear, vinId, uniId, hon_Version }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorariosHeader> listado = new List<esq_BOB_HonorariosHeader>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorariosHeader obj = new esq_BOB_HonorariosHeader();
                    {
                        obj.hon_Id = dr["hon_Id"].ToString();
                        obj.uni_Id = dr["uni_Id"].ToString();
                        obj.sed_Id = dr["sed_Id"].ToString();
                        obj.sed_Nombre = dr["sed_Nombre"].ToString();
                        obj.vin_Id = dr["vin_Id"].ToString();
                        obj.hon_Month = int.Parse(dr["hon_Month"].ToString());
                        obj.hon_Year = int.Parse(dr["hon_Year"].ToString());
                        obj.hon_Version = int.Parse(dr["hon_Version"].ToString());
                        obj.hon_CantidadDetalle = int.Parse(dr["hon_CantidadDetalle"].ToString());

                        obj.hon_MontoVenta = decimal.Parse(dr["hon_MontoVenta"].ToString());
                        obj.hon_TotalDescuento = decimal.Parse(dr["hon_TotalDescuento"].ToString());
                        obj.hon_SubTotalVenta = decimal.Parse(dr["hon_SubTotalVenta"].ToString());
                        obj.hon_TotalConvenio = decimal.Parse(dr["hon_TotalConvenio"].ToString());
                        obj.hon_MontoDescuento1 = decimal.Parse(dr["hon_MontoDescuento1"].ToString());
                        obj.hon_MontoDescuento2 = decimal.Parse(dr["hon_MontoDescuento2"].ToString());
                        obj.hon_MontoDescuentoOtros = decimal.Parse(dr["hon_MontoDescuentoOtros"].ToString());
                        obj.hon_ConceptoDescuentoOtros = dr["hon_ConceptoDescuentoOtros"].ToString();
                        obj.hon_SubTotalConvenio = decimal.Parse(dr["hon_SubTotalConvenio"].ToString());

                        obj.hon_PorcImpuesto1 = decimal.Parse(dr["hon_PorcImpuesto1"].ToString());
                        obj.hon_MontoImpuesto1 = decimal.Parse(dr["hon_MontoImpuesto1"].ToString());
                        obj.hon_ConceptoImpuesto1 = dr["hon_ConceptoImpuesto1"].ToString();

                        obj.hon_PorcImpuesto2 = decimal.Parse(dr["hon_PorcImpuesto2"].ToString());
                        obj.hon_MontoImpuesto2 = decimal.Parse(dr["hon_MontoImpuesto2"].ToString());
                        obj.hon_ConceptoImpuesto2 = dr["hon_ConceptoImpuesto2"].ToString();

                        obj.hon_PorcImpuesto3 = decimal.Parse(dr["hon_PorcImpuesto3"].ToString());
                        obj.hon_MontoImpuesto3 = decimal.Parse(dr["hon_MontoImpuesto3"].ToString());
                        obj.hon_ConceptoImpuesto3 = dr["hon_ConceptoImpuesto3"].ToString();

                        obj.hon_MontoTotal = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorariosBody> GetBodyHonorariosPorVinId(int honMonth, int honYear, string vinId, string uniId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hop_BodyHonorariosPorVinId",
                    new string[] { "@hon_Month", "@hon_Year", "@vinId", "@uniId" },
                    new object[] { honMonth, honYear, vinId, uniId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorariosBody> listado = new List<esq_BOB_HonorariosBody>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorariosBody obj = new esq_BOB_HonorariosBody();
                    {
                        obj.hod_Id = dr["hop_Id"].ToString();
                        obj.hon_Id = dr["hon_Id"].ToString();
                        obj.fpa_Id = dr["fpa_Id"].ToString();
                        obj.fpa_Nombre = dr["fpa_Nombre"].ToString();
                        obj.ser_Id = dr["ser_Id"].ToString();
                        obj.ser_Nombre = dr["ser_Nombre"].ToString();
                        obj.sed_Id = dr["sed_Id"].ToString();
                        obj.sed_Nombre = dr["sed_Nombre"].ToString();
                        obj.hop_Version = int.Parse(dr["hop_Version"].ToString());

                        obj.pac_FullName = dr["pac_FullName"].ToString();
                        obj.pac_Identificacion = dr["pac_Identificacion"].ToString();

                        obj.hod_SubtotalVenta = decimal.Parse(dr["hop_SubtotalVenta"].ToString());
                        obj.hod_PorcDescuentoAVoluntad = decimal.Parse(dr["hop_PorcDescuentoAVoluntad"].ToString());
                        obj.hod_MontoDescuentoAVoluntad = decimal.Parse(dr["hop_MontoDescuentoAVoluntad"].ToString());
                        obj.hod_ConceptoDescuentoAVoluntad = dr["hop_ConceptoDescuentoAVoluntad"].ToString();
                        obj.hod_ResponsableDescuento = dr["hop_ResponsableDescuento"].ToString();

                        obj.hod_TotalVenta = decimal.Parse(dr["hop_TotalVenta"].ToString());
                        obj.hod_PorcConvenio = decimal.Parse(dr["hop_PorcConvenio"].ToString());
                        obj.hod_MontoConvenio = decimal.Parse(dr["hop_MontoConvenio"].ToString());
                        obj.hod_PorcDescuento1 = decimal.Parse(dr["hop_PorcDescuento1"].ToString());
                        obj.hod_MontoDescuento1 = decimal.Parse(dr["hop_MontoDescuento1"].ToString());
                        obj.hod_ConceptoDescuento1 = dr["hop_ConceptoDescuento1"].ToString();

                        obj.hod_PorcDescuento2 = decimal.Parse(dr["hop_PorcDescuento2"].ToString());
                        obj.hod_MontoDescuento2 = decimal.Parse(dr["hop_MontoDescuento2"].ToString());
                        obj.hod_ConceptoDescuento2 = dr["hop_ConceptoDescuento2"].ToString();

                        obj.hod_Total = decimal.Parse(dr["hop_Total"].ToString());

                        obj.hod_Descripcion = dr["hop_Descripcion"].ToString();
                        obj.hod_Estatus = dr["hod_Estatus"].ToString();

                        obj.con_Fecha = Convert.ToDateTime(dr["con_Fecha"]).ToShortDateString();

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorariosBody> GetBodyHonorariosVersionPorVinId(int honMonth, int honYear, string vinId, string uniId, string version)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hop_BodyHonorariosVersionPorVinId",
                    new string[] { "@hon_Month", "@hon_Year", "@vinId", "@uniId", "@hon_Version" },
                    new object[] { honMonth, honYear, vinId, uniId, version }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorariosBody> listado = new List<esq_BOB_HonorariosBody>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorariosBody obj = new esq_BOB_HonorariosBody();
                    {
                        obj.hod_Id = dr["hop_Id"].ToString();
                        obj.hon_Id = dr["hon_Id"].ToString();
                        obj.fpa_Id = dr["fpa_Id"].ToString();
                        obj.fpa_Nombre = dr["fpa_Nombre"].ToString();
                        obj.ser_Id = dr["ser_Id"].ToString();
                        obj.ser_Nombre = dr["ser_Nombre"].ToString();
                        obj.sed_Id = dr["sed_Id"].ToString();
                        obj.sed_Nombre = dr["sed_Nombre"].ToString();
                        obj.hop_Version = int.Parse(dr["hop_Version"].ToString());

                        obj.pac_FullName = dr["pac_FullName"].ToString();
                        obj.pac_Identificacion = dr["pac_Identificacion"].ToString();

                        obj.hod_SubtotalVenta = decimal.Parse(dr["hop_SubtotalVenta"].ToString());
                        obj.hod_PorcDescuentoAVoluntad = decimal.Parse(dr["hop_PorcDescuentoAVoluntad"].ToString());
                        obj.hod_MontoDescuentoAVoluntad = decimal.Parse(dr["hop_MontoDescuentoAVoluntad"].ToString());
                        obj.hod_ConceptoDescuentoAVoluntad = dr["hop_ConceptoDescuentoAVoluntad"].ToString();
                        obj.hod_ResponsableDescuento = dr["hop_ResponsableDescuento"].ToString();

                        obj.hod_TotalVenta = decimal.Parse(dr["hop_TotalVenta"].ToString());
                        obj.hod_PorcConvenio = decimal.Parse(dr["hop_PorcConvenio"].ToString());
                        obj.hod_MontoConvenio = decimal.Parse(dr["hop_MontoConvenio"].ToString());
                        obj.hod_PorcDescuento1 = decimal.Parse(dr["hop_PorcDescuento1"].ToString());
                        obj.hod_MontoDescuento1 = decimal.Parse(dr["hop_MontoDescuento1"].ToString());
                        obj.hod_ConceptoDescuento1 = dr["hop_ConceptoDescuento1"].ToString();

                        obj.hod_PorcDescuento2 = decimal.Parse(dr["hop_PorcDescuento2"].ToString());
                        obj.hod_MontoDescuento2 = decimal.Parse(dr["hop_MontoDescuento2"].ToString());
                        obj.hod_ConceptoDescuento2 = dr["hop_ConceptoDescuento2"].ToString();

                        obj.hod_Total = decimal.Parse(dr["hop_Total"].ToString());

                        obj.hod_Descripcion = dr["hop_Descripcion"].ToString();
                        obj.hod_Estatus = dr["hod_Estatus"].ToString();


                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        #endregion

        #region WorkFlow

        public AResult InsWorkflowPagoBegin(string paiId, string iMonth, string iYear, string uniId, string vinId, string usuario)
        {
            AResult are = new AResult();
            are.Name = "SetReCalculoHonorarios";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pi_Wfp_WorkflowPagoBegin",
                    new string[] { "@paiId", "@honMonth", "@honYear", "@uniId", "@vinId", "@Usuario" },
                    new object[] { paiId, iMonth, iYear, uniId, vinId, usuario }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id1 = "";
                string _Id2 = "";
                if (dt.Rows.Count > 0)
                {
                    _Id1 = dt.Rows[0]["wfg_Id"].ToString();
                    _Id2= dt.Rows[0]["wfp_Id"].ToString();
                }

                are.Id = _Id1;
                are.Id2 = _Id2;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public AResult InsWorkflowPagoNext(string wfgId, string wfpId, string wfhId, string wfpComentario, string wfpImagenName, string wfpImagenContentType, byte[] wfpImagen, string uniId, string vinId, string Usuario)
        {
            AResult are = new AResult();
            are.Name = "InsWorkflowPagoNext";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pi_Wfp_WorkflowPagoNext",
                    new string[] { "@wfgId", "@wfpId", "@wfhId", "@wfpComentario", "@wfpImagenName", "@wfpImagenContentType", "@wfpImagen", "@uniId", "@vinId", "@Usuario" },
                    new object[] { wfgId, wfpId, wfhId, wfpComentario, wfpImagenName, wfpImagenContentType, wfpImagen, uniId, vinId, Usuario }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id1 = "";
                string _Id2 = "";
                if (dt.Rows.Count > 0)
                {
                    _Id1 = dt.Rows[0]["wfg_Id"].ToString();
                    _Id2 = dt.Rows[0]["wfp_Id"].ToString();
                }

                are.Id = _Id1;
                are.Id2 = _Id2;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public AResult InsWorkflowPagoNextSinDocumento(string wfgId, string wfpId, string wfhId, string wfpComentario, string uniId, string vinId, string Usuario)
        {
            AResult are = new AResult();
            are.Name = "InsWorkflowPagoNextSinDocumento";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pi_Wfp_WorkflowPagoNextSinDocumento",
                    new string[] { "@wfgId", "@wfpId", "@wfhId", "@wfpComentario", "@uniId", "@vinId", "@Usuario" },
                    new object[] { wfgId, wfpId, wfhId, wfpComentario, uniId, vinId, Usuario }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id1 = "";
                string _Id2 = "";
                if (dt.Rows.Count > 0)
                {
                    _Id1 = dt.Rows[0]["wfg_Id"].ToString();
                    _Id2 = dt.Rows[0]["wfp_Id"].ToString();
                }

                are.Id = _Id1;
                are.Id2 = _Id2;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public esq_BOB_WorkFlowEstadoPago GetWorkFlowEstadoPago(int honMonth, int honYear, string uniId, string vinId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Wfp_WorkflowPagoEstadoActualPorHorId",
                    new string[] { "@hon_Month", "@hon_Year", "@uniId", "@vinId" },
                    new object[] { honMonth, honYear, uniId, vinId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_WorkFlowEstadoPago> listado = new List<esq_BOB_WorkFlowEstadoPago>();

                foreach (DataRow dr in dt.Rows)
                {
                    bool realizado = bool.Parse(dr["wfp_Realizado"].ToString());
                    bool wfe_Finaliza = bool.Parse(dr["wfe_Finaliza"].ToString());
                    bool wfe_Inicia = bool.Parse(dr["wfe_Inicia"].ToString());
                    //if ((!realizado) && (wfe_Finaliza) || (!realizado) && (wfe_Inicia))
                    if (!realizado)
                    {
                        esq_BOB_WorkFlowEstadoPago obj = new esq_BOB_WorkFlowEstadoPago();
                        {
                            obj.wfg_Id = dr["wfg_Id"].ToString();
                            obj.wfp_Id = dr["wfp_Id"].ToString();
                            obj.wfe_Id = dr["wfe_Id"].ToString();
                            obj.wfh_Id = dr["wfh_Id"].ToString();
                            obj.wfp_Responsable = dr["wfp_Responsable"].ToString();
                            obj.wfh_Responsable = dr["wfh_Responsable"].ToString();
                            obj.wfe_Descripcion = dr["wfe_Descripcion"].ToString();
                            obj.wfp_Comentario = dr["wfp_Comentario"].ToString();
                            obj.wfe_RequiereComentario = bool.Parse(dr["wfe_RequiereComentario"].ToString());
                            obj.wfe_RequiereArchivo = bool.Parse(dr["wfe_RequiereArchivo"].ToString());

                            if ((dr["wfp_Imagen"] != null) && (Convert.ToString(dr["wfp_Imagen"]) != ""))
                            {
                                obj.wfp_Imagen = (byte[])dr["wfp_Imagen"];

                                var base64 = Convert.ToBase64String(obj.wfp_Imagen);
                                var imgSrc = String.Format("data:image/jpg;base64,{0}", base64);
                                obj.wfp_StrImagen = imgSrc;

                                obj.wfp_ImagenName = Convert.ToString(dr["wfp_ImagenName"]);
                                obj.wfp_ImagenContentType = Convert.ToString(dr["wfp_ImagenContentType"]);
                            }

                            if ((dr["wfp_ImagenAnt"] != null) && (Convert.ToString(dr["wfp_ImagenAnt"]) != ""))
                            {
                                obj.wfp_ImagenAnt = (byte[])dr["wfp_ImagenAnt"];

                                var base64 = Convert.ToBase64String(obj.wfp_ImagenAnt);
                                var imgSrc = String.Format("data:image/jpg;base64,{0}", base64);
                                obj.wfp_StrImagenAnt = imgSrc;

                                obj.wfp_ImagenNameAnt = Convert.ToString(dr["wfp_ImagenNameAnt"]);
                                obj.wfp_ImagenContentTypeAnt = Convert.ToString(dr["wfp_ImagenContentTypeAnt"]);
                            }

                            obj.wfp_ResponsableAnt = dr["wfp_ResponsableAnt"].ToString();
                            obj.wfp_ComentarioAnt = dr["wfp_ComentarioAnt"].ToString();

                            obj.wfp_Realizado= bool.Parse(dr["wfp_Realizado"].ToString());
                            obj.wfe_Inicia = bool.Parse(dr["wfe_Inicia"].ToString());
                            obj.wfe_Finaliza = bool.Parse(dr["wfe_Finaliza"].ToString());

                            obj.wfp_Id_Ant = dr["wfp_Id_Ant"].ToString();

                            listado.Add(obj);
                            obj = null; //-->Vaciar Vaeriable

                            break;
                        }
                    }
                    else if (!realizado && wfe_Finaliza)
                    {
                        esq_BOB_WorkFlowEstadoPago obj = new esq_BOB_WorkFlowEstadoPago();
                        {
                            obj.wfg_Id = dr["wfg_Id"].ToString();
                            obj.wfp_Id = dr["wfp_Id"].ToString();
                            obj.wfe_Id = dr["wfe_Id"].ToString();
                            obj.wfh_Id = dr["wfh_Id"].ToString();
                            obj.wfp_Responsable = dr["wfp_Responsable"].ToString();
                            obj.wfh_Responsable = dr["wfh_Responsable"].ToString();
                            obj.wfe_Descripcion = dr["wfe_Descripcion"].ToString();
                            obj.wfp_Comentario = dr["wfp_Comentario"].ToString();
                            obj.wfe_RequiereComentario = bool.Parse(dr["wfe_RequiereComentario"].ToString());
                            obj.wfe_RequiereArchivo = bool.Parse(dr["wfe_RequiereArchivo"].ToString());

                            if ((dr["wfp_Imagen"] != null) && (Convert.ToString(dr["wfp_Imagen"]) != ""))
                            {
                                obj.wfp_Imagen = (byte[])dr["wfp_Imagen"];

                                var base64 = Convert.ToBase64String(obj.wfp_Imagen);
                                var imgSrc = String.Format("data:image/jpg;base64,{0}", base64);
                                obj.wfp_StrImagen = imgSrc;

                                obj.wfp_ImagenName = Convert.ToString(dr["wfp_ImagenName"]);
                                obj.wfp_ImagenContentType = Convert.ToString(dr["wfp_ImagenContentType"]);
                            }

                            if ((dr["wfp_ImagenAnt"] != null) && (Convert.ToString(dr["wfp_ImagenAnt"]) != ""))
                            {
                                obj.wfp_ImagenAnt = (byte[])dr["wfp_ImagenAnt"];

                                var base64 = Convert.ToBase64String(obj.wfp_ImagenAnt);
                                var imgSrc = String.Format("data:image/jpg;base64,{0}", base64);
                                obj.wfp_StrImagenAnt = imgSrc;

                                obj.wfp_ImagenNameAnt = Convert.ToString(dr["wfp_ImagenNameAnt"]);
                                obj.wfp_ImagenContentTypeAnt = Convert.ToString(dr["wfp_ImagenContentTypeAnt"]);
                            }

                            obj.wfp_ResponsableAnt = dr["wfp_ResponsableAnt"].ToString();
                            obj.wfp_ComentarioAnt = dr["wfp_ComentarioAnt"].ToString();

                            obj.wfp_Realizado = bool.Parse(dr["wfp_Realizado"].ToString());
                            obj.wfe_Inicia = bool.Parse(dr["wfe_Inicia"].ToString());
                            obj.wfe_Finaliza = bool.Parse(dr["wfe_Finaliza"].ToString());

                            obj.wfp_Id_Ant = dr["wfp_Id_Ant"].ToString();

                            listado.Add(obj);
                            obj = null; //-->Vaciar Vaeriable
                            break;
                        }
                    };
                }

                //-->Fin Cargar los datos a Objeto
                if (listado.Count > 0)
                {
                    return listado[0];
                }
                else
                {
                    return null;
                }
                
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_wfe_WorkflowEstatus> GetNextEstados(int wfhId, string paiId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Wfa_WorkflowHonorarioAccionPorWfhId",
                    new string[] { "@wfhId", "@paiId" },
                    new object[] { wfhId, paiId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_wfe_WorkflowEstatus> listado = new List<esq_BOB_wfe_WorkflowEstatus>();

                foreach (DataRow dr in dt.Rows)
                {
                   
                    esq_BOB_wfe_WorkflowEstatus obj = new esq_BOB_wfe_WorkflowEstatus();
                    {
                        obj.wfe_Id = dr["wfe_Id"].ToString();
                        obj.wfe_Descripcion = dr["wfe_Descripcion"].ToString();
                        obj.wfe_DescripcionAccion = dr["wfe_DescripcionAccion"].ToString();

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                        
                    };
                }

                //-->Fin Cargar los datos a Objeto
                
                    return listado;
                

            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public wfp_BOBDocumento GetDocumento(Guid wfpId)
        {
            wfp_BOBDocumento obj = new wfp_BOBDocumento();

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Wfp_WorkflowPagoPorId",
                    new string[] { "@wfpId" },
                    new object[] { wfpId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                foreach (DataRow dr in dt.Rows)
                {

                    obj.wfp_NombrePdf = dr["wfp_ImagenName"].ToString();
                    obj.wfp_ExtensionPdf = dr["wfp_ImagenContentType"].ToString();
                    obj.wfp_Pdf = (byte[])dr["wfp_Imagen"];

                    var base64 = Convert.ToBase64String(obj.wfp_Pdf);
                    var imgSrc = String.Format("data:image/jpg;base64,{0}", base64);
                    obj.wfp_PdfBase64 = imgSrc;
                }
            }
            catch (Exception ex)
            {
                base.CloseConnection();
            }
            finally
            {
                base.CloseConnection();
            }
            return obj;
        }

        public wfp_BOBDocumento GetDocumentoAdjuntoProfesional(Guid phnId)
        {
            wfp_BOBDocumento obj = new wfp_BOBDocumento();

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_phn_VerBoletaAdjunta",
                    new string[] { "@phn_Id" },
                    new object[] { phnId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                foreach (DataRow dr in dt.Rows)
                {

                    obj.wfp_NombrePdf = dr["phn_ImagenName"].ToString();
                    obj.wfp_ExtensionPdf = dr["phn_ImagenContentType"].ToString();
                    obj.wfp_Pdf = (byte[])dr["phn_Imagen"];

                    var base64 = Convert.ToBase64String(obj.wfp_Pdf);
                    var imgSrc = String.Format("data:image/jpg;base64,{0}", base64);
                    obj.wfp_PdfBase64 = imgSrc;
                }
            }
            catch (Exception ex)
            {
                base.CloseConnection();
            }
            finally
            {
                base.CloseConnection();
            }
            return obj;
        }

        #endregion

        #region Profesional

        public List<esq_BOB_HonorarioConsolidado> GetHonorariosProfesionalesPeriodoActualPorDsuId(string dsuId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_HonorariosProfesionalesPeriodoActualPorDsuId",
                    new string[] { "@dsuId" },
                    new object[] { dsuId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioConsolidado> listado = new List<esq_BOB_HonorarioConsolidado>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioConsolidado obj = new esq_BOB_HonorarioConsolidado();
                    {
                        obj.vinId = dr["vin_Id"].ToString();
                        obj.honId = dr["hon_Id"].ToString();
                        obj.uniId = dr["uni_Id"].ToString();
                        obj.uni_Nombre = dr["uni_NombreLegal"].ToString();
                        obj.Profesional = dr["fullNamePme"].ToString();
                        obj.PorcentajeConvenio = decimal.Parse(dr["vin_PorcConvenio"].ToString()).ToString("N0");
                        obj.TotalServicios = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        int iMonth = int.Parse(dr["hon_Month"].ToString());
                        int iYear = int.Parse(dr["hon_Year"].ToString());

                        obj.ListSede = GetHonorariosProfesionalesPorUniId(iMonth, iYear, obj.uniId, obj.vinId);
                        obj.ObjWfp = GetWorkFlowEstadoPago(iMonth, iYear, obj.uniId, obj.vinId);

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorarioConsolidado> GetHonorariosProfesionalesPeriodoActualPorVinId(string vinId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_HonorariosProfesionalesPeriodoActualPorVinId",
                    new string[] { "@vinId" },
                    new object[] { vinId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioConsolidado> listado = new List<esq_BOB_HonorarioConsolidado>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioConsolidado obj = new esq_BOB_HonorarioConsolidado();
                    {
                        obj.vinId = dr["vin_Id"].ToString();
                        obj.honId = dr["hon_Id"].ToString();
                        obj.uniId = dr["uni_Id"].ToString();
                        obj.uni_Nombre = dr["uni_NombreLegal"].ToString();
                        obj.Profesional = dr["fullNamePme"].ToString();
                        obj.PorcentajeConvenio = decimal.Parse(dr["vin_PorcConvenio"].ToString()).ToString("N0");
                        obj.TotalServicios = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        int iMonth = int.Parse(dr["hon_Month"].ToString());
                        int iYear = int.Parse(dr["hon_Year"].ToString());

                        obj.ListSede = GetHonorariosProfesionalesPorUniId(iMonth, iYear, obj.uniId, obj.vinId);
                        obj.ObjWfp = GetWorkFlowEstadoPago(iMonth, iYear, obj.uniId, obj.vinId);

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorarioProfesionalEnProcesoPorUnidadServicio> GetWorkflowGestionPagoEnProcesoPorDsuId(string dsuId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Wfg_WorkflowGestionPagoEnProcesoPorDsuId",
                    new string[] { "@dsuId" },
                    new object[] { dsuId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioProfesionalEnProcesoPorUnidadServicio> listado = new List<esq_BOB_HonorarioProfesionalEnProcesoPorUnidadServicio>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioProfesionalEnProcesoPorUnidadServicio obj = new esq_BOB_HonorarioProfesionalEnProcesoPorUnidadServicio();
                    {
                        obj.vinId = dr["vin_Id"].ToString();
                        obj.uniId = dr["uni_Id"].ToString();
                        obj.uni_Nombre = dr["uni_NombreLegal"].ToString();
                        obj.TotalServicios = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        obj.ListPeriodo = GetWorkflowGestionPagoEnProcesoPorPeriodo(obj.vinId);
                        

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorarioProfesionalEnProcesoPorUnidadServicio> GetWorkflowGestionPagoEnProcesoPorVinId(string vinId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Wfg_WorkflowGestionPagoEnProcesoPorVinId",
                    new string[] { "@vinId" },
                    new object[] { vinId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioProfesionalEnProcesoPorUnidadServicio> listado = new List<esq_BOB_HonorarioProfesionalEnProcesoPorUnidadServicio>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioProfesionalEnProcesoPorUnidadServicio obj = new esq_BOB_HonorarioProfesionalEnProcesoPorUnidadServicio();
                    {
                        obj.vinId = dr["vin_Id"].ToString();
                        obj.uniId = dr["uni_Id"].ToString();
                        obj.uni_Nombre = dr["uni_NombreLegal"].ToString();
                        obj.TotalServicios = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        obj.ListPeriodo = GetWorkflowGestionPagoEnProcesoPorPeriodo(obj.vinId);


                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }



                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public List<esq_BOB_HonorarioProfesionalEnProcesoPorPeriodo> GetWorkflowGestionPagoEnProcesoPorPeriodo(string vinId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Wfg_WorkflowGestionPagoEnProcesoPorPeriodo",
                    new string[] { "@vinId" },
                    new object[] { vinId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<esq_BOB_HonorarioProfesionalEnProcesoPorPeriodo> listado = new List<esq_BOB_HonorarioProfesionalEnProcesoPorPeriodo>();

                foreach (DataRow dr in dt.Rows)
                {
                    esq_BOB_HonorarioProfesionalEnProcesoPorPeriodo obj = new esq_BOB_HonorarioProfesionalEnProcesoPorPeriodo();
                    {
                        obj.uniId = dr["uni_Id"].ToString();
                        obj.iMonth = dr["hon_Month"].ToString();
                        obj.iYear = dr["hon_Year"].ToString();
                        obj.FullDate = obj.iMonth + "-" + obj.iYear;
                        obj.TotalServicios = decimal.Parse(dr["hon_MontoTotal"].ToString());

                        obj.ListSede = GetHonorariosProfesionalesPorUniId(int.Parse(obj.iMonth), int.Parse(obj.iYear), obj.uniId, vinId);
                        obj.ObjWfp = GetWorkFlowEstadoPago(int.Parse(obj.iMonth), int.Parse(obj.iYear), obj.uniId, vinId);

                        listado.Add(obj);
                        obj = null; //-->Vaciar Vaeriable
                    };
                }

                //-->Fin Cargar los datos a Objeto

                return listado;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        #endregion

        #region Nuevo Honorarios por Profesional

        public AResult SetConfirmarServicio(string uniId, string vinId, string iMonth, string iYear, string usuario, string fadId)
        {
            AResult are = new AResult();
            are.Name = "SetConfirmarServicio";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pi_hop_HonorarioProfesional",
                    new string[] { "@uniId", "@vinId", "@hon_Month", "@hon_Year", "@usuario", "@fadId" },
                    new object[] { uniId, vinId, iMonth, iYear, usuario, fadId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public esq_BOB_DashboardHonorarioPorProfesional GetHonorarioProfesionalDashboard(string vinId, int honMonth, int honYear)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_hop_HonorarioProfesionalDashboard",
                    new string[] { "@vin_Id", "@hon_Month", "@hon_Year" },
                    new object[] { vinId, honMonth, honYear }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                //-->Cargar los datos a Objeto
                esq_BOB_DashboardHonorarioPorProfesional obj = new esq_BOB_DashboardHonorarioPorProfesional();
                                    
                obj.hon_MontoBruto = decimal.Parse(dt.Rows[0]["hon_Saldo"].ToString());
                obj.hon_MontoValidado = decimal.Parse(dt.Rows[0]["hon_SaldoValidado"].ToString());
                obj.hon_MontoPagado = decimal.Parse(dt.Rows[0]["hon_MontoPagado"].ToString());
                obj.hon_CantServicios = int.Parse(dt.Rows[0]["hon_CantServicios"].ToString());
                obj.hon_CantPacientes = int.Parse(dt.Rows[0]["hon_CantPacientes"].ToString());
                obj.hon_CantDiasEfectivos = int.Parse(dt.Rows[0]["hon_CantDiasEfectivos"].ToString());
                obj.hon_MontoBrutoHonorarios = decimal.Parse(dt.Rows[0]["fad_Total_Honorarios"].ToString());

                //-->Fin Cargar los datos a Objeto

                return obj;
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public AResult SetEliminarConfirmarServicio(string vinId, string usuario, string fadId)
        {
            AResult are = new AResult();
            are.Name = "SetEliminarConfirmarServicio";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pd_Hop_HonorarioProfesionalPorFadId",
                    new string[] { "@vinId", "@usuario", "@fadId" },
                    new object[] { vinId, usuario, fadId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }


        #endregion

        #region Pago de Honorarios

        public AResult InsSetPagoHonorariosSolicitarBoleta(string uni_Id, string vin_Id, string hon_Month, string hon_Year, string cbc_Id, string phn_ComentarioUni, string usuario, int hon_Version)
        {
            AResult are = new AResult();
            are.Name = "InsSetPagoHonorariosSolicitarBoleta";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pi_Phn_PagoHonorario",
                    new string[] { "@uni_Id", "@vin_Id", "@hon_Month", "@hon_Year", "@cbc_Id", "@phn_ComentarioUni", "@Usuario", "@hon_Version" },
                    new object[] { uni_Id, vin_Id, hon_Month, hon_Year, cbc_Id, phn_ComentarioUni, usuario, hon_Version }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id1 = "";
                if (dt.Rows.Count > 0)
                {
                    _Id1 = dt.Rows[0]["Id"].ToString();                    
                }

                are.Id = _Id1;
                
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public cbc_CuentaBancaria GetHon_ValidaCuentaHonorarioPorVinId(string uniId, string vinId, string hon_Month, string hon_Year)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_ValidaCuentaHonorarioPorVinId",
                    new string[] { "@uniId", "@vinId", "@hon_Month", "@hon_Year" },
                    new object[] { uniId, vinId, hon_Month, hon_Year }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                cbc_CuentaBancaria obj = new cbc_CuentaBancaria();

                foreach (DataRow dr in dt.Rows)
                {                    
                    obj.cbc_Id = dr["cbc_Id"].ToString();
                    obj.ban_Nombre = dr["ban_Nombre"].ToString();
                    obj.tcb_Nombre = dr["tcb_Nombre"].ToString();
                    obj.cbc_NombreTitular = dr["cbc_NombreTitular"].ToString();
                    obj.cbc_NroCuenta = dr["cbc_NroCuenta"].ToString();
                    obj.cbc_Email = dr["cbc_Email"].ToString();
                }

                //-->Fin Cargar los datos a Objeto

                return obj;
            }
            catch (Exception)
            {
                base.CloseConnection();
                return null;
            }
            finally
            {
                base.CloseConnection();
            }
        }

        public AResult GetValidacionPagoHonorarioPorVinId(string uniId, string vinId, string hon_Month, string hon_Year)
        {
            AResult are = new AResult();
            try
            {
                
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.ps_Hon_ValidarAprobacionPagoPorVinId",
                    new string[] { "@uniId", "@vinId", "@hon_Month", "@hon_Year" },
                    new object[] { uniId, vinId, hon_Month, hon_Year }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string phn_BoletaAdjunta = "";
                string phn_Pagado = "";
                string solicitudRealizada = "0";
                if (dt.Rows.Count > 0)
                {
                    phn_BoletaAdjunta = dt.Rows[0]["phn_BoletaAdjunta"].ToString();
                    phn_Pagado = dt.Rows[0]["phn_Pagado"].ToString();
                    solicitudRealizada = "1";
                }

                if (solicitudRealizada == "1")
                    are.Exists = true;
                else
                    are.Exists = false;


                are.Id = phn_BoletaAdjunta;
                are.Id2 = phn_Pagado;

                are.IsError = false;

            }
            catch (Exception)
            {
                base.CloseConnection();
                are.IsError = true;
            }
            finally
            {
                base.CloseConnection();
            }

            return are;
        }

        public AResult InsAnularAprobacionPagoPorVinId(string uni_Id, string vin_Id, string hon_Month, string hon_Year, string usuario, int hon_Version)
        {
            AResult are = new AResult();
            are.Name = "InsAnularAprobacionPagoPorVinId";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pu_Hon_AnularAprobacionPagoPorVinId",
                    new string[] { "@uni_Id", "@vin_Id", "@hon_Month", "@hon_Year", "@Usuario", "@hon_Version" },
                    new object[] { uni_Id, vin_Id, hon_Month, hon_Year, usuario, hon_Version }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id1 = "";
                if (dt.Rows.Count > 0)
                {
                    _Id1 = dt.Rows[0]["Id"].ToString();
                }

                are.Id = _Id1;

                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public AResult SetAdjuntarBoletaHonorarios(string phn_Id, string phn_Nombre, string phn_Extension, byte[] phn_Imagen, string usuario)
        {
            AResult are = new AResult();
            are.Name = "SetProcesarCierreHonorarios";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pu_phn_PagoHonorarioAdjuntarBoleta",
                    new string[] { "@phn_Id", "@phn_Nombre", "@phn_Extension", "@phn_Imagen", "@usuario" },
                    new object[] { phn_Id, phn_Nombre, phn_Extension, phn_Imagen, usuario }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        public AResult SetPagarHonorarios(string uni_Id, string vin_Id, int hon_Month, int hon_Year, string cbc_Id, string phn_MontoPagado, string phn_DescripcionPago, string hon_Id, int phnVersion)
        {
            AResult are = new AResult();
            are.Name = "SetProcesarCierreHonorarios";

            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("honorario.pu_phn_PagarHonorarios",
                    new string[] { "@uni_Id", "@vin_Id", "@hon_Month", "@hon_Year", "@cbc_Id", "@phn_MontoPagado", "@phn_DescripcionPago", "@hon_Id", "@phn_Version" },
                    new object[] { uni_Id, vin_Id, hon_Month, hon_Year, cbc_Id, phn_MontoPagado, phn_DescripcionPago, hon_Id, phnVersion }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures

                string _Id = "";
                if (dt.Rows.Count > 0)
                    _Id = dt.Rows[0]["Id"].ToString();

                are.Id = _Id;
                are.IsError = false;
                are.Message = "";
            }
            catch (Exception ex)
            {
                base.CloseConnection();
                are.IsError = true;
                are.Message = ex.Message;
            }
            finally
            {
                base.CloseConnection();
            }
            return are;
        }

        #endregion

    }
}
