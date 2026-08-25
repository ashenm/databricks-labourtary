resource "databricks_sql_endpoint" "warehouses" {
  for_each                  = var.warehouses
  name                      = coalesce(each.value.name, upper(join("-", compact([var.name_prefix, each.key]))))
  cluster_size              = each.value.size
  min_num_clusters          = each.value.min_num_clusters
  max_num_clusters          = each.value.max_num_clusters
  auto_stop_mins            = each.value.auto_stop_mins
  spot_instance_policy      = each.value.spot_instance_policy
  enable_serverless_compute = each.value.enable_serverless_compute
  warehouse_type            = each.value.type
  no_wait                   = each.value.no_wait

  channel {
    name = each.value.channel
  }

  tags {
    dynamic "custom_tags" {
      for_each = each.value.custom_tags

      content {
        key   = custom_tags.key
        value = custom_tag.value
      }
    }
  }
}
