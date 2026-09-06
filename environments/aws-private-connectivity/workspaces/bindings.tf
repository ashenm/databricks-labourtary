resource "databricks_workspace_binding" "triangulum" {
  for_each       = jsondecode(data.external.workspaces.result.workspaces)
  securable_name = module.catalogs.catalogs["triangulum"].name
  workspace_id   = each.value.id
}

data "external" "workspaces" {
  program = ["python3", "${path.root}/../../externals/get-workspaces.py"]
  query = {
    workspace_url = data.databricks_current_user.current.workspace_url
  }
}
