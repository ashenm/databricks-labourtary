resource "databricks_schema" "schemas" {
  for_each     = var.schemas
  name         = lower(coalesce(each.value.name, replace(each.key, "-", "_")))
  catalog_name = data.databricks_catalog.schemas[each.value.catalog_name].name
  storage_root = each.value.storage_root
  owner        = each.value.owner
}

resource "databricks_grants" "schemas" {
  for_each = { for key, value in var.schemas : key => value if length(coalesce(value.permissions, [])) != 0 }
  schema   = databricks_schema.schemas[each.key].id

  dynamic "grant" {
    for_each = each.value.permissions

    content {
      principal  = data.databricks_group.schemas[grant.value.group].display_name
      privileges = grant.value.privileges
    }
  }
}

data "databricks_catalog" "schemas" {
  for_each = toset([for key, schema in var.schemas : schema.catalog_name])
  name     = each.key
}

data "databricks_group" "schemas" {
  for_each     = toset(flatten([for key, schema in var.schemas : [for permission in schema.permissions : permission.group]]))
  display_name = each.key
}
