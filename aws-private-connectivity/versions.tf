terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "1.95.0"
    }
  }
  required_version = ">= 1.10.0"
}
