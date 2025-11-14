resource "databricks_catalog" "main" {
  name         = "main"
  storage_root = databricks_external_location.unity_catalog.url
}

resource "databricks_storage_credential" "unity_catalog" {
  name           = "unity-catalog"
  isolation_mode = "ISOLATED"

  aws_iam_role {
    role_arn = local.unity_catalog_role_arn
  }
}

resource "time_sleep" "databricks_storage_credential" {
  create_duration = "30s"
  depends_on      = [aws_iam_role.unity_catalog]
}

resource "databricks_external_location" "unity_catalog" {
  name            = "unity-catalog"
  url             = "s3://${aws_s3_bucket.unity_catalog.id}/main"
  credential_name = databricks_storage_credential.unity_catalog.name
}

resource "aws_s3_bucket" "unity_catalog" {
  bucket = lower("${var.name_prefix}-unity-catalog")
}
