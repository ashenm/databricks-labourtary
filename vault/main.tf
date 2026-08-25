provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {}
  }
}

locals {
  keys = {
    sudoers-private-key-openssh = trimspace(tls_private_key.main.private_key_openssh)
    sudoers-public-key-openssh  = trimspace(tls_private_key.main.public_key_openssh)
  }
}
