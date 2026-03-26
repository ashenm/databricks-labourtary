resource "aws_s3_bucket" "storages" {
  for_each      = var.storages
  bucket        = local.storage_bucket_names[each.key]
  force_destroy = each.value.force_destroy
  tags          = { Tier = "Data" }
}

resource "aws_s3_bucket_versioning" "storages" {
  for_each = var.storages
  bucket   = aws_s3_bucket.storages[each.key].bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storages" {
  for_each = var.storages
  bucket   = aws_s3_bucket.storages[each.key].bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.storages[each.key].arn
      sse_algorithm     = "aws:kms"
    }

    bucket_key_enabled       = true
    blocked_encryption_types = ["SSE-C"]
  }
}
