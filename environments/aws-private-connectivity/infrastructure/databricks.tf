resource "databricks_mws_workspaces" "main" {
  workspace_name             = lower(var.name_prefix)
  account_id                 = var.databricks_account_id
  aws_region                 = data.aws_region.current.region
  network_id                 = databricks_mws_networks.main.network_id
  storage_configuration_id   = databricks_mws_storage_configurations.main.storage_configuration_id
  credentials_id             = databricks_mws_credentials.main.credentials_id
  private_access_settings_id = databricks_mws_private_access_settings.main.private_access_settings_id
  pricing_tier               = "ENTERPRISE"
  deployment_name            = var.project_name
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

resource "databricks_mws_vpc_endpoint" "relay" {
  account_id          = var.databricks_account_id
  vpc_endpoint_name   = lower("${var.name_prefix}-relay")
  aws_vpc_endpoint_id = aws_vpc_endpoint.interfaces["relay"].id
  region              = data.aws_region.current.region
}

resource "databricks_mws_vpc_endpoint" "rest" {
  account_id          = var.databricks_account_id
  vpc_endpoint_name   = lower("${var.name_prefix}-rest")
  aws_vpc_endpoint_id = aws_vpc_endpoint.interfaces["rest"].id
  region              = data.aws_region.current.region
}

resource "databricks_mws_networks" "main" {
  account_id         = var.databricks_account_id
  network_name       = lower(var.name_prefix)
  security_group_ids = [aws_security_group.databricks.id]
  subnet_ids         = slice(aws_subnet.databricks.*.id, 0, 2)

  vpc_endpoints {
    dataplane_relay = [databricks_mws_vpc_endpoint.relay.vpc_endpoint_id]
    rest_api        = [databricks_mws_vpc_endpoint.rest.vpc_endpoint_id]
  }

  vpc_id = aws_vpc.main.id
}

resource "databricks_mws_private_access_settings" "main" {
  private_access_settings_name = lower(var.name_prefix)
  region                       = data.aws_region.current.region
  public_access_enabled        = true
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
