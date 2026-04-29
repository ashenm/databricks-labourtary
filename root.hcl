terraform {
  source = "${get_repo_root()}//${path_relative_to_include()}"
}

remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    path = "${get_terragrunt_dir()}/terraform.tfstate"
  }
}

generate "versions" {
  path      = "versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = file("${get_repo_root()}/templates/versions.tftpl")
}
