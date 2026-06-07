resource "databricks_mws_network_connectivity_config" "main" {
  #
  # TEMP
  # Hard-coding region and reverse dns prefix instead of
  # using following due to resource being marked for recreation on some runs
  # data.aws_region.current.region
  #
  region = "ap-southeast-1"
  name   = lower(var.name_prefix)
}

resource "databricks_mws_ncc_private_endpoint_rule" "main" {
  #
  # TEMP
  # Hard-coding region and reverse dns prefix instead of
  # using following due to resource being marked for recreation on some runs
  # "${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.region}.s3"
  #
  account_id                     = var.databricks_account_id
  endpoint_service               = "com.amazonaws.ap-southeast-1.s3"
  network_connectivity_config_id = databricks_mws_network_connectivity_config.main.network_connectivity_config_id
  resource_names                 = [for resource in data.aws_resourcegroupstaggingapi_resources.buckets.resource_tag_mapping_list : replace(resource.resource_arn, "arn:aws:s3:::", "")]
}

resource "databricks_mws_ncc_binding" "main" {
  workspace_id                   = var.databricks_workspace_id
  network_connectivity_config_id = databricks_mws_network_connectivity_config.main.network_connectivity_config_id
  depends_on                     = [databricks_mws_ncc_private_endpoint_rule.main]
}

resource "databricks_account_network_policy" "main" {
  network_policy_id = lower(var.name_prefix)
  account_id        = var.databricks_account_id

  egress = {
    network_access = {
      restriction_mode = "FULL_ACCESS"
    }
  }
}

resource "databricks_workspace_network_option" "main" {
  workspace_id      = var.databricks_workspace_id
  network_policy_id = databricks_account_network_policy.main.network_policy_id
}

data "aws_resourcegroupstaggingapi_resources" "buckets" {
  resource_type_filters = ["s3"]

  tag_filter {
    key    = "Project"
    values = [upper(var.project_name)]
  }

  tag_filter {
    key    = "Environment"
    values = [upper(var.environment)]
  }

  tag_filter {
    key    = "Tier"
    values = ["Data"]
  }
}

data "aws_partition" "current" {}
data "aws_region" "current" {}
