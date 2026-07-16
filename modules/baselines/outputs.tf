output "drivers" {
  value = [for key, value in local.drivers : merge(value, { path = databricks_file.drivers[key].path })]
}

output "team_job_compute_policy_id" {
  value = local.create_team_policies ? one(databricks_cluster_policy.job_compute_team.*.policy_id) : null
}

output "user_job_compute_policy_id" {
  value = local.create_user_policies ? one(databricks_cluster_policy.job_compute_user.*.policy_id) : null
}

output "sql_starter_warehouse" {
  value = {
    id          = databricks_sql_endpoint.starter_warehouse.id
    jdbc_url    = databricks_sql_endpoint.starter_warehouse.jdbc_url
    state       = databricks_sql_endpoint.starter_warehouse.state
    permissions = local.sql_starter_warehouse_acls
  }
}
