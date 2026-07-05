resource "databricks_artifact_allowlist" "init" {
  artifact_type = "INIT_SCRIPT"

  dynamic "artifact_matcher" {
    for_each = jsondecode(data.external.artifact_allowlist_matchers_init.result.matchers)

    content {
      artifact   = artifact_matcher.value.artifact
      match_type = artifact_matcher.value.match_type
    }
  }
}

resource "databricks_artifact_allowlist" "jars" {
  artifact_type = "LIBRARY_JAR"

  dynamic "artifact_matcher" {
    for_each = jsondecode(data.external.artifact_allowlist_matchers_jars.result.matchers)

    content {
      artifact   = artifact_matcher.value.artifact
      match_type = artifact_matcher.value.match_type
    }
  }
}

data "external" "artifact_allowlist_matchers_init" {
  program = ["python3", "${path.module}/../../../externals/get-artifact-allowlist.py"]
  query = {
    host   = data.databricks_current_user.current.workspace_url
    type   = "INIT_SCRIPT"
    prefix = "/Volumes/${module.schemas.schemas["main"].catalog_name}/${module.schemas.schemas["main"].name}"
    paths = jsonencode([
      module.volumes.volumes["probes"].volume_path,
      module.volumes.volumes["rovers"].volume_path,
    ])
  }
  depends_on = [module.volumes]
}

data "external" "artifact_allowlist_matchers_jars" {
  program = ["python3", "${path.module}/../../../externals/get-artifact-allowlist.py"]
  query = {
    host   = data.databricks_current_user.current.workspace_url
    type   = "LIBRARY_JAR"
    prefix = "/Volumes/${module.schemas.schemas["main"].catalog_name}/${module.schemas.schemas["main"].name}"
    paths  = jsonencode([module.volumes.volumes["drivers"].volume_path])
  }
  depends_on = [module.volumes]
}
