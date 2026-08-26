provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {}
  }
}

provider "databricks" {
  host = "https://accounts.cloud.databricks.com"
}

resource "databricks_metastore" "main" {
  name          = var.metastore_name
  force_destroy = true
  region        = var.aws_region
  owner         = databricks_group.sudoers.display_name

  delta_sharing_scope                               = "INTERNAL_AND_EXTERNAL"
  delta_sharing_recipient_token_lifetime_in_seconds = 2592000
  delta_sharing_organization_name                   = var.metastore_name
}

resource "databricks_metastore" "auxiliary" {
  name          = "${var.metastore_name}-auxiliary"
  force_destroy = true
  region        = var.aws_region_auxiliary
  owner         = databricks_group.sudoers.display_name

  delta_sharing_scope                               = "INTERNAL_AND_EXTERNAL"
  delta_sharing_recipient_token_lifetime_in_seconds = 2592000
  delta_sharing_organization_name                   = "${var.metastore_name}-auxiliary"
}

resource "databricks_mws_network_connectivity_config" "main" {
  name   = "metastore"
  region = var.aws_region
}

data "external" "service_principal" {
  program = ["python3", "${path.module}/externals/get-current-service-principal.py"]
  query   = {}
}
