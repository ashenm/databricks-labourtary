locals {
  storage_role_names   = { for key, value in var.storages : key => upper(join("-", compact([var.name_prefix, key]))) }
  storage_bucket_names = { for key, value in var.storages : key => coalesce(value.bucket_name, lower(replace(join("-", compact([var.name_prefix, key])), "_", "-"))) }
}

resource "databricks_storage_credential" "storages" {
  for_each       = var.storages
  name           = lower(join("-", compact([var.name_prefix, each.key])))
  isolation_mode = "ISOLATION_MODE_ISOLATED"
  force_destroy  = each.value.force_destroy

  aws_iam_role {
    role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.storage_role_names[each.key]}"
  }
}

resource "databricks_external_location" "storages" {
  for_each        = var.storages
  name            = lower(join("-", compact([var.name_prefix, each.key])))
  url             = "s3://${local.storage_bucket_names[each.key]}/"
  credential_name = databricks_storage_credential.storages[each.key].name
  isolation_mode  = "ISOLATION_MODE_ISOLATED"
  force_destroy   = each.value.force_destroy

  encryption_details {
    sse_encryption_details {
      algorithm       = "AWS_SSE_KMS"
      aws_kms_key_arn = aws_kms_alias.storages[each.key].arn
    }
  }

  depends_on = [aws_s3_bucket.storages, time_sleep.databricks_external_location]
}

resource "time_sleep" "databricks_external_location" {
  for_each        = var.storages
  create_duration = "30s"
  depends_on      = [aws_iam_role.storages, aws_iam_role_policy.storages, databricks_storage_credential.storages]
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
