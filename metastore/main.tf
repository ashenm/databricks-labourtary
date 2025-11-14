provider "aws" {
  region = var.aws_region
}

provider "databricks" {}

resource "databricks_metastore" "main" {
  name          = var.metastore_name
  force_destroy = true
  owner         = databricks_group.sudoers.display_name
  region        = var.aws_region
}

resource "databricks_group" "sudoers" {
  display_name = lower("${var.metastore_name}-sudoers")
}
