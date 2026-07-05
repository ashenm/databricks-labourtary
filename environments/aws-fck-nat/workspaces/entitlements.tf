resource "databricks_entitlements" "users" {
  group_id                   = data.databricks_group.users.id
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = false
  workspace_access           = false
}

resource "databricks_entitlements" "readers" {
  group_id                   = data.databricks_group.readers.id
  allow_cluster_create       = false
  allow_instance_pool_create = false
  workspace_consume          = true
}

resource "databricks_entitlements" "sudoers" {
  group_id                   = data.databricks_group.sudoers.id
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = true
  workspace_access           = true
}
