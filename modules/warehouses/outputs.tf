output "warehouses" {
  value = { for key, value in var.warehouses : key => {
    id          = databricks_sql_endpoint.warehouses[key].id
    jdbc_url    = databricks_sql_endpoint.warehouses[key].jdbc_url
    odbc_params = databricks_sql_endpoint.warehouses[key].odbc_params
    state       = databricks_sql_endpoint.warehouses[key].state
  } }
}
