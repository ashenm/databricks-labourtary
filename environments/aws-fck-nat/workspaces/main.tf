locals {
  unity_catalog_bucket_name = lower("${var.name_prefix}-unity-catalog")
  configs                   = merge([for filepath in fileset("${path.module}/config", "*.yaml") : yamldecode(file("${path.module}/config/${filepath}"))]...)

  catalogs = { for key, value in lookup(local.configs, "catalogs", {}) : key => merge(value, {
    storage_root = lookup(value, "storage", null) != null ? "${trimsuffix(module.storages.storage_locations[value.storage].url, "/")}/default" : null
  }) }

  clusters = { for key, value in lookup(local.configs, "clusters", {}) : key => merge(value, {
    libraries = concat(lookup(value, "libraries", []), [for idx, value in module.baselines.drivers : { type = value.type, destination = value.path }])
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
  clusters    = local.clusters
  name_prefix = var.name_prefix
  depends_on  = [databricks_artifact_allowlist.init]
}

module "baselines" {
  source           = "../../../modules/baselines"
  cluster_policies = ["team", "user"]
  volume_path      = module.volumes.volumes["drivers"].volume_path
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
