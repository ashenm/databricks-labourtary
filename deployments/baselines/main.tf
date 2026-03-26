locals {
  artifacts   = fileset("${path.module}/artifacts/", "*")
  schema_info = one(data.databricks_schema.baselines.schema_info)
}

provider "databricks" {
  host = var.databricks_workspace_url
}

resource "databricks_global_init_script" "baselines" {
  source  = "${path.module}/artifacts/ini.sh"
  name    = "environment-baselines"
  enabled = true
}

resource "databricks_volume" "baselines" {
  name         = "databricks_baselines"
  volume_type  = "MANAGED"
  catalog_name = local.schema_info.catalog_name
  schema_name  = local.schema_info.name
}

resource "databricks_file" "baselines" {
  for_each = local.artifacts
  source   = "${path.module}/artifacts/${each.key}"
  path     = "${databricks_volume.baselines.volume_path}/${each.key}"
}

resource "databricks_artifact_allowlist" "baselines" {
  artifact_type = "INIT_SCRIPT"

  dynamic "artifact_matcher" {
    for_each = jsondecode(data.external.artifact_allowlist_matchers.result.matchers)

    content {
      artifact   = artifact_matcher.value.artifact
      match_type = artifact_matcher.value.match_type
    }
  }
}

data "external" "artifact_allowlist_matchers" {
  program = ["python3", "${path.module}/../../externals/get-artifact-allowlist.py"]
  query = {
    host   = data.databricks_current_user.current.workspace_url
    prefix = dirname(databricks_volume.baselines.volume_path)
    paths  = jsonencode([databricks_volume.baselines.volume_path])
  }
}

data "databricks_schema" "baselines" {
  name = var.schema
}

data "databricks_current_user" "current" {}
