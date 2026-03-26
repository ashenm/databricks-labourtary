locals {
  artifacts = fileset("${path.module}/artifacts", "**")
  scripts   = fileset("${path.module}/scripts", "*.sh")
}

resource "databricks_file" "artifacts" {
  for_each = local.artifacts
  source   = "${path.module}/artifacts/${each.key}"
  path     = "${var.artifacts.volume_path}/artifacts/${basename(each.key)}"
}

resource "databricks_file" "scripts" {
  for_each = local.scripts
  source   = "${path.module}/scripts/${each.key}"
  path     = "${var.artifacts.volume_path}/scripts/${basename(each.key)}"
}

resource "databricks_artifact_allowlist" "scripts" {
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
  program = ["python3", "${path.module}/../../../externals/get-artifact-allowlist.py"]
  query = {
    host   = data.databricks_current_user.current.workspace_url
    prefix = dirname(var.artifacts.volume_path)
    paths  = jsonencode([var.artifacts.volume_path])
  }
}

data "databricks_current_user" "current" {}
