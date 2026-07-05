resource "databricks_file" "drivers" {
  for_each = local.drivers
  source   = "${path.module}/drivers/${each.value.source}"
  path     = "${var.volume_path}/${each.key}"
}
