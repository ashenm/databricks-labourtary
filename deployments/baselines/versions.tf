terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
  }
}
