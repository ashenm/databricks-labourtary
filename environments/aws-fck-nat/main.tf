locals {
  name_prefix = upper("${var.environment}-${var.project}")
}

provider "aws" {
  default_tags {
    tags = {
      Project     = upper(var.project)
      Environment = upper(var.environment)
    }
  }
}

provider "databricks" {
  alias      = "mws"
  host       = "https://accounts.cloud.databricks.com"
  account_id = var.databricks_account_id
}

provider "databricks" {
  alias = "workspace"
  host  = module.infrastructure.workspace_url
}

module "infrastructure" {
  source                  = "./infrastructure"
  databricks_account_id   = var.databricks_account_id
  name_prefix             = local.name_prefix
  project_name            = var.project
  providers               = { databricks = databricks.mws }
  databricks_metastore_id = var.databricks_metastore_id
}

module "workspaces" {
  source      = "./workspaces"
  name_prefix = local.name_prefix
  providers   = { databricks = databricks.workspace }
  depends_on  = [module.infrastructure]
}

module "serverless" {
  source                  = "./serverless"
  name_prefix             = local.name_prefix
  databricks_account_id   = var.databricks_account_id
  databricks_workspace_id = module.infrastructure.workspace_id
  project_name            = var.project
  environment             = var.environment
  providers               = { databricks = databricks.mws }
  depends_on              = [module.infrastructure, module.workspaces]
}
