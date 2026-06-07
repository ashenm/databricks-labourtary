provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Owner = "hewagallage.gunaratne@databricks.com"
    }
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
  delta_sharing_organization_name                   = "one-env-laboratory"
}

data "external" "service_principal" {
  program = ["python3", "${path.module}/externals/get-current-service-principal.py"]
  query   = {}
}
