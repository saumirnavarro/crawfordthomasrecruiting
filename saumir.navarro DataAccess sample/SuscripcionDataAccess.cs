using CSaludObject.BusinessObjects;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CSaludDataAccess.BusinessDataAccess
{
    public class SuscripcionDataAccess : AccessDataConnections.Entity
    {
        #region Constructor
        public SuscripcionDataAccess()
            : base("CnnCSaludDB")
        {
            base.OpenConnection();
        }
        public SuscripcionDataAccess(SqlConnection objSQLConnection)
            : base(objSQLConnection)
        {
        }
        #endregion

        #region Producto Suscripcion

        public List<psu_BOBProductoSuscripcion> GetProductoSuscripcionPorSusId(string susId)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("suscripcion.ps_Psu_ProductoSuscripcionPorSusId",
                    new string[] { "@sus_Id" },
                    new object[] { susId }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<psu_BOBProductoSuscripcion> listado = new List<psu_BOBProductoSuscripcion>();

                foreach (DataRow dr in dt.Rows)
                {
                    psu_BOBProductoSuscripcion obj = new psu_BOBProductoSuscripcion();
                    {
                        obj.psu_Id = Int64.Parse(dr["psu_Id"].ToString());
                        obj.sus_Id = Guid.Parse(dr["sus_Id"].ToString());

                        obj.psu_Estatus = bool.Parse(dr["psu_Estatus"].ToString());
                        obj.psu_FechaCre = DateTime.Parse(dr["psu_FechaCre"].ToString());
                        obj.psu_UsuarioCre = dr["psu_UsuarioCre"].ToString();
                        obj.psu_UsuarioEli = dr["psu_UsuarioEli"].ToString();
                        obj.pro_Id = Guid.Parse(dr["pro_Id"].ToString());
                        obj.pro_CodigoInterno = dr["pro_CodigoInterno"].ToString();
                        obj.prp_Id = Guid.Parse(dr["prp_Id"].ToString());
                        obj.prp_CodigoInterno = dr["prp_CodigoInterno"].ToString();

                        if (dr["psu_FechaEli"].ToString() != "")
                        {
                            obj.psu_FechaEli = DateTime.Parse(dr["psu_FechaEli"].ToString());
                        }

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

        #region Plan Producto

        public List<prp_BOBProductoPlanPago> GetProductoPlanPagoPorProId(string proCodigoInterno)
        {
            try
            {
                //-->Obtener o Ejecutar los datos del Stored Procedures
                DataTable dt = new DataTable();
                dt = base.ExecuteStoredProcedure("suscripcion.ps_Prp_ProductoPlanPagoPorProId",
                    new string[] { "@pro_CodigoInterno" },
                    new object[] { proCodigoInterno }).Tables[0];
                //-->Fin Obtener o Ejecutar los datos del Stored Procedures
                //-->Cargar los datos a Objeto
                List<prp_BOBProductoPlanPago> listado = new List<prp_BOBProductoPlanPago>();

                foreach (DataRow dr in dt.Rows)
                {
                    prp_BOBProductoPlanPago obj = new prp_BOBProductoPlanPago();
                    {
                        obj.prp_Id = Guid.Parse(dr["prp_Id"].ToString());
                        obj.pro_Id = Guid.Parse(dr["pro_Id"].ToString());

                        obj.prp_CodigoInterno = dr["prp_CodigoInterno"].ToString();
                        obj.prp_Nombre = dr["prp_Nombre"].ToString();
                        obj.prp_Descripcion = dr["prp_Descripcion"].ToString();
                        obj.prp_Precio = double.Parse(dr["prp_Precio"].ToString());
                        obj.prp_EsGratis = bool.Parse(dr["prp_EsGratis"].ToString());
                        obj.prp_ModoVigencia = dr["prp_ModoVigencia"].ToString();
                        obj.prp_Vigencia = int.Parse(dr["prp_Vigencia"].ToString());

                        obj.prp_Estatus = bool.Parse(dr["prp_Estatus"].ToString());
                        obj.prp_FechaCre = DateTime.Parse(dr["prp_FechaCre"].ToString());
                        obj.prp_UsuarioCre = dr["prp_UsuarioCre"].ToString();
                        obj.prp_UsuarioEli = dr["prp_UsuarioEli"].ToString();

                        obj.prp_NombreAlias = double.Parse(dr["prp_Precio"].ToString()).ToString("N2") + " - " + dr["prp_Nombre"].ToString();

                        if (dr["prp_FechaEli"].ToString() != "")
                        {
                            obj.prp_FechaEli = DateTime.Parse(dr["prp_FechaEli"].ToString());
                        }

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
    }
}
