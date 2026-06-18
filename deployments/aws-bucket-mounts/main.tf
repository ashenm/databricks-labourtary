provider "databricks" {
  host = var.databricks_workspace_url
}

module "storages" {
  source = "../../modules/storages"
  storages = {
    main = {
      bucket_name   = "one-env-voyager-cyclones"
      force_destroy = true
    }
  }
}

resource "databricks_volume" "main" {
  name             = "cyclones"
  catalog_name     = "triangulum"
  schema_name      = "stars"
  volume_type      = "EXTERNAL"
  owner            = "one-env-laboratory-sudoers"
  storage_location = module.storages.storage_locations.main.url
}

resource "aws_s3_object" "main" {
  bucket         = "one-env-voyager-cyclones"
  key            = "example.txt"
  content_base64 = base64encode("hello, world!")
  etag           = md5(base64encode("hello, world!"))
  depends_on     = [module.storages]
}

resource "databricks_grants" "main" {
  volume = databricks_volume.main.id

  grant {
    principal  = "one-env-laboratory-readers"
    privileges = ["READ_VOLUME"]
  }
}
