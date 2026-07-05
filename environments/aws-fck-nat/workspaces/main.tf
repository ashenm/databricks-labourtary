locals {
  unity_catalog_bucket_name = lower("${var.name_prefix}-unity-catalog")
  configs                   = merge([for filepath in fileset("${path.module}/config", "*.yaml") : yamldecode(file("${path.module}/config/${filepath}"))]...)

  catalogs = { for key, value in lookup(local.configs, "catalogs", {}) : key => merge(value, {
    storage_root = lookup(value, "storage", null) != null ? "${trimsuffix(module.storages.storage_locations[value.storage].url, "/")}/default" : null
  }) }
}

module "storages" {
  source      = "../../../modules/storages"
  storages    = lookup(local.configs, "storages", {})
  name_prefix = var.name_prefix
}

module "catalogs" {
  source      = "../../../modules/catalogs"
  catalogs    = local.catalogs
  name_prefix = var.name_prefix
  depends_on  = [module.storages]
}

module "schemas" {
  source     = "../../../modules/schemas"
  schemas    = lookup(local.configs, "schemas", {})
  depends_on = [module.catalogs]
}

module "volumes" {
  source     = "../../../modules/volumes"
  volumes    = lookup(local.configs, "volumes", {})
  depends_on = [module.schemas]
}

module "clusters" {
  source      = "../../../modules/clusters"
  clusters    = lookup(local.configs, "clusters", {})
  name_prefix = var.name_prefix
  depends_on  = [databricks_artifact_allowlist.init]
}

module "baselines" {
  source           = "../../../modules/baselines"
  cluster_policies = ["team", "user"]
}

resource "databricks_workspace_conf" "main" {
  custom_config = {
    enableTokensConfig   = "true"
    maxTokenLifetimeDays = "360"
  }
}

resource "databricks_permissions" "tokens" {
  authorization = "tokens"

  access_control {
    group_name       = "one-env-laboratory-sudoers"
    permission_level = "CAN_USE"
  }
}

resource "databricks_default_namespace_setting" "main" {
  namespace {
    value = module.catalogs.catalogs["main"].name
  }
}

resource "databricks_disable_legacy_access_setting" "main" {
  disable_legacy_access {
    value = true
  }
}

resource "databricks_file" "init" {
  source = "${path.module}/artifacts/init.sh"
  path   = "${module.volumes.volumes["probes"].volume_path}/init.sh"
}

resource "databricks_artifact_allowlist" "init" {
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
    prefix = dirname(module.volumes.volumes["probes"].volume_path)
    paths = jsonencode([
      module.volumes.volumes["probes"].volume_path,
      module.volumes.volumes["rovers"].volume_path
    ])
  }
  depends_on = [module.volumes]
}

data "databricks_group" "readers" {
  display_name = "one-env-laboratory-readers"
}

data "databricks_group" "sudoers" {
  display_name = "one-env-laboratory-sudoers"
}

data "databricks_group" "users" {
  display_name = "users"
}

data "databricks_current_user" "current" {}
