resource "aws_s3_bucket" "databricks" {
  bucket        = lower("${var.name_prefix}-databricks")
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "databricks" {
  bucket                  = aws_s3_bucket.databricks.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "databricks" {
  bucket = aws_s3_bucket.databricks.id
  policy = data.databricks_aws_bucket_policy.main.json
}
