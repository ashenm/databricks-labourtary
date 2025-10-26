output "bucket_name" {
  value = aws_s3_bucket.databricks.bucket
}

output "workspace_url" {
  value = databricks_mws_workspaces.main.workspace_url
}

output "groups" {
  value = {
    sudoers = {
      id               = databricks_group.sudoers.id
      acl_principal_id = databricks_group.sudoers.acl_principal_id
    }
  }
}
