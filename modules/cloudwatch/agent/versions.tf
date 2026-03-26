terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.100"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}
