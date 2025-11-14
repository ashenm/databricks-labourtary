output "bucket_name" {
  value = aws_s3_bucket.databricks.bucket
}

output "workspace_url" {
  value = databricks_mws_workspaces.main.workspace_url
}
