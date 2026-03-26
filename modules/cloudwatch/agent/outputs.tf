locals {
  environment_suffix = {
    prod = "prd"
    nprd = "nprd"
  }
}

output "artifacts" {
  value = { for key, value in local.artifacts : key => {
    id   = databricks_file.artifacts[key].id
    path = databricks_file.artifacts[key].path
    size = databricks_file.artifacts[key].file_size
  } }
}

output "scripts" {
  value = { for key, value in local.scripts : key => {
    id   = databricks_file.scripts[key].id
    path = databricks_file.scripts[key].path
    size = databricks_file.scripts[key].file_size
  } }
}
