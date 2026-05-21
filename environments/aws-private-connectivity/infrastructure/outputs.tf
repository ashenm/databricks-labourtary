output "aws_vpc_id" {
  value = aws_vpc.main.id
}

output "workspace_id" {
  value = databricks_mws_workspaces.main.workspace_id
}

output "workspace_bucket_name" {
  value = aws_s3_bucket.databricks.bucket
}

output "workspace_url" {
  value = databricks_mws_workspaces.main.workspace_url
}
