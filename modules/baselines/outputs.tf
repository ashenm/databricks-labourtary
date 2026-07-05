output "drivers" {
  value = [for key, value in local.drivers : merge(value, { path = databricks_file.drivers[key].path })]
}

output "team_job_compute_policy_id" {
  value = local.create_team_policies ? one(databricks_cluster_policy.job_compute_team.*.policy_id) : null
}

output "user_job_compute_policy_id" {
  value = local.create_user_policies ? one(databricks_cluster_policy.job_compute_user.*.policy_id) : null
}
