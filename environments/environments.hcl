dependency "metastore" {
  config_path = "${get_terragrunt_dir()}/../../metastore"

  mock_outputs = {
    metastore_id  = "000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["plan"]
}

inputs = {
  aws_region            = get_env("AWS_REGION", "ap-southeast-1")
  environment           = "one-env"
  databricks_account_id = get_env("DATABRICKS_ACCOUNT_ID")
  databricks_metastore_id = dependency.metastore.outputs.metastore_id
}
