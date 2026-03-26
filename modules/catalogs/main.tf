resource "databricks_catalog" "catalogs" {
  for_each       = var.catalogs
  name           = lower(coalesce(each.value.name, replace(join("-", compact([var.name_prefix, each.key])), "-", "_")))
  storage_root   = each.value.storage_root
  isolation_mode = "ISOLATED"
  owner          = each.value.owner
}

resource "databricks_grants" "catalogs" {
  catalog  = databricks_catalog.catalogs[each.key].name
  for_each = { for key, value in var.catalogs : key => value if length(coalesce(value.permissions, [])) != 0 }

  dynamic "grant" {
    for_each = each.value.permissions

    content {
      principal  = data.databricks_group.catalogs[grant.value.group].display_name
      privileges = grant.value.privileges
    }
  }
}

data "databricks_group" "catalogs" {
  for_each     = toset(flatten([for key, catalog in var.catalogs : [for permission in catalog.permissions : permission.group]]))
  display_name = each.key
}
