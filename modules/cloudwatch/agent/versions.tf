terraform {
  required_providers {
    databricks = {
      source  = "databricks/databricks"
      version = "~> 1.129"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}
