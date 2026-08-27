terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    databricks = {
      source = "databricks/databricks"
    }
    external = {
      source = "hashicorp/external"
    }
  }
  required_version = ">= 1.10.0"
}
