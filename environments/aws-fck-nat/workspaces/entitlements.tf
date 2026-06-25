resource "databricks_entitlements" "users" {
  group_id                   = data.databricks_group.users.id
  allow_cluster_create       = false
  allow_instance_pool_create = false
  databricks_sql_access      = true
  workspace_access           = true
}
