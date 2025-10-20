locals {
  name_prefix = upper("${var.environment}-${var.project}")
}

provider "aws" {
  region = var.aws_region
}

provider "databricks" {
  alias      = "mws"
  account_id = var.databricks_account_id
}

provider "databricks" {
  alias = "workspace"
  host  = module.infrastructure.workspace_url
}

module "infrastructure" {
  source                = "./infrastructure"
  databricks_account_id = var.databricks_account_id
  name_prefix           = local.name_prefix
  project_name          = var.project
  providers             = { databricks = databricks.mws }
}

module "workspaces" {
  source      = "./workspaces"
  name_prefix = local.name_prefix
  providers   = { databricks = databricks.workspace }
  depends_on  = [module.infrastructure]
}
