output "schemas" {
  value = { for key, value in var.schemas : key => {
    id           = databricks_schema.schemas[key].id
    name         = databricks_schema.schemas[key].name
    catalog_name = databricks_schema.schemas[key].name
  } }
}
