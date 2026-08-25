terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27"
    }
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.129"
    }
  }
}
