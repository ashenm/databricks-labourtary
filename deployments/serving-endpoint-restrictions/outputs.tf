output "scripts" {
  value = { for script in local.scripts : script => {
    path = databricks_workspace_file.scripts[script].path
    md5  = data.local_file.scripts[script].content_md5
  } }
}
