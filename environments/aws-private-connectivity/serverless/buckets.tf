resource "aws_s3_bucket" "logs" {
  bucket        = lower("${var.name_prefix}-logs")
  force_destroy = true
  tags          = { Tier = "Logs" }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket = aws_s3_bucket.logs.bucket
  policy = data.aws_iam_policy_document.logs.json
}
