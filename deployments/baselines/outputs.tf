output "artifacts" {
  value = { for artifact in local.artifacts : artifact => {
    id   = databricks_file.baselines[artifact].id
    path = databricks_file.baselines[artifact].path
  } }
}

output "global_init_script" {
  value = {
    id = databricks_global_init_script.baselines.id
  }
}
