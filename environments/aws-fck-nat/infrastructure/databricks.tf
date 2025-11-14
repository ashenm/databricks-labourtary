resource "databricks_mws_workspaces" "main" {
  workspace_name           = lower(var.name_prefix)
  account_id               = var.databricks_account_id
  aws_region               = data.aws_region.current.region
  network_id               = databricks_mws_networks.main.network_id
  storage_configuration_id = databricks_mws_storage_configurations.main.storage_configuration_id
  credentials_id           = databricks_mws_credentials.main.credentials_id
  deployment_name          = var.project_name
}

resource "databricks_metastore_assignment" "main" {
  metastore_id = var.databricks_metastore_id
  workspace_id = databricks_mws_workspaces.main.workspace_id
}

resource "time_sleep" "databricks_mws_credentials" {
  depends_on      = [aws_iam_role.databricks]
  create_duration = "30s"
}

resource "databricks_mws_credentials" "main" {
  credentials_name = lower(var.name_prefix)
  role_arn         = aws_iam_role.databricks.arn
  depends_on       = [time_sleep.databricks_mws_credentials]
}

resource "databricks_mws_storage_configurations" "main" {
  account_id                 = var.databricks_account_id
  storage_configuration_name = lower(var.name_prefix)
  bucket_name                = aws_s3_bucket.databricks.bucket
}

resource "databricks_mws_networks" "main" {
  account_id         = var.databricks_account_id
  network_name       = lower(var.name_prefix)
  security_group_ids = [aws_security_group.databricks.id]
  subnet_ids         = aws_subnet.databricks.*.id
  vpc_id             = aws_vpc.main.id
}

data "databricks_aws_assume_role_policy" "main" {
  external_id = var.databricks_account_id
}

data "databricks_aws_crossaccount_policy" "main" {
  policy_type       = "customer"
  region            = data.aws_region.current.region
  security_group_id = aws_security_group.databricks.id
  vpc_id            = aws_vpc.main.id
}

data "databricks_aws_bucket_policy" "main" {
  bucket = aws_s3_bucket.databricks.bucket
}
