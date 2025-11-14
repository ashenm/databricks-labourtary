data "databricks_aws_unity_catalog_assume_role_policy" "main" {
  aws_account_id = data.aws_caller_identity.current.account_id
  external_id    = one(databricks_storage_credential.unity_catalog.aws_iam_role.*.external_id)
  role_name      = local.unity_catalog_role_name
}

data "databricks_aws_unity_catalog_policy" "main" {
  aws_account_id = data.aws_caller_identity.current.account_id
  bucket_name    = aws_s3_bucket.unity_catalog.bucket
  role_name      = local.unity_catalog_role_name
}
