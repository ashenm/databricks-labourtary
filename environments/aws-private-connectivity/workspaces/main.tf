locals {
  unity_catalog_bucket_name = lower("${var.name_prefix}-unity-catalog")
  configs                   = merge([for filepath in fileset("${path.module}/config", "*.yaml") : yamldecode(file("${path.module}/config/${filepath}"))]...)

  catalogs = { for key, value in lookup(local.configs, "catalogs", {}) : key => merge(value, {
    storage_root = lookup(value, "storage", null) != null ? "${trimsuffix(module.storages.storage_locations[value.storage].url, "/")}/default" : null
  }) }

  clusters = { for key, value in lookup(local.configs, "clusters", {}) : key => merge(value, {
    instance_profile_arn = lookup(value, "instance_profile", null) != null ? module.instance_profiles.instance_profiles[value.instance_profile].id : null
    ssh_public_keys      = [local.vault["sudoers-public-key-openssh"]]
    init_scripts = concat(lookup(value, "init_scripts", []), [
      {
        type        = "volume"
        destination = module.cloudwatch.agent.scripts["install.sh"].path
      }
    ])
    spark_env_vars = merge(lookup(value, "spark_env_vars", {}), {
      CLOUDWATCH_INSTALLER_TYPE      = "offline"
      CLOUDWATCH_INSTALLER_DIRECTORY = module.volumes.volumes["cloudwatch"].volume_path
    })
  }) }

  instance_profile_policies = {
    cloudwatch_agent_serverpolicy = data.aws_iam_policy.cloudwatch_agent_serverpolicy.policy
  }

  instance_profiles = { for key, value in lookup(local.configs, "instance_profiles", {}) : key => merge(value, {
    policies = [for idx, policy in value.policies : merge(policy, { policy = local.instance_profile_policies[policy.policy] })]
  }) }

  vault = jsondecode(data.aws_secretsmanager_secret_version.vault.secret_string)
}

data "aws_secretsmanager_secret_version" "vault" {
  secret_id     = one(data.aws_secretsmanager_secrets.vault.arns)
  version_stage = "AWSCURRENT"
}

data "aws_secretsmanager_secrets" "vault" {
  filter {
    name   = "name"
    values = ["one-env-laboratory"]
  }
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

module "cloudwatch" {
  source = "../../../modules/cloudwatch"
  agent = {
    artifacts = {
      volume_path = module.volumes.volumes["cloudwatch"].volume_path
    }
  }
  depends_on = [module.volumes]
}

module "instance_profiles" {
  source            = "../../../modules/instance-profiles"
  instance_profiles = local.instance_profiles
  name_prefix       = var.name_prefix
}

module "clusters" {
  source      = "../../../modules/clusters"
  clusters    = local.clusters
  name_prefix = var.name_prefix
}

resource "databricks_workspace_conf" "main" {
  custom_config = {
    enableTokensConfig  = "false"
    enableIpAccessLists = "false"
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
    prefix = dirname(module.volumes.volumes["cloudwatch"].volume_path)
    paths  = jsonencode([module.volumes.volumes["cloudwatch"].volume_path])
  }
}

data "databricks_current_user" "current" {}
