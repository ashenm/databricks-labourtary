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
