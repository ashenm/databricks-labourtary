locals {
  artifacts = fileset("${path.module}/artifacts", "**")
  scripts   = fileset("${path.module}/scripts", "*.sh")
}

resource "databricks_file" "artifacts" {
  for_each = local.artifacts
  source   = "${path.module}/artifacts/${each.key}"
  path     = "${var.artifacts.volume_path}/artifacts/${basename(each.key)}"
}

resource "databricks_file" "scripts" {
  for_each = local.scripts
  source   = "${path.module}/scripts/${each.key}"
  path     = "${var.artifacts.volume_path}/scripts/${basename(each.key)}"
}

data "databricks_current_user" "current" {}
