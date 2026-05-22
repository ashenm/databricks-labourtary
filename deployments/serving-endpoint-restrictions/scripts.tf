resource "databricks_directory" "automations" {
  path             = "/Workspace/Automations"
  delete_recursive = true
}

resource "databricks_workspace_file" "scripts" {
  for_each = local.scripts
  path     = "${databricks_directory.automations.path}/${each.key}"
  source   = data.local_file.scripts[each.key].filename
  md5      = data.local_file.scripts[each.key].content_md5
}

data "local_file" "scripts" {
  for_each = local.scripts
  filename = "${path.module}/${each.key}"
}
