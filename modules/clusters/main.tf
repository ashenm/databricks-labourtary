resource "databricks_cluster" "clusters" {
  for_each            = var.clusters
  num_workers         = each.value.num_workers
  cluster_name        = coalesce(each.value.name, upper(join("-", compact([var.name_prefix, each.key]))))
  spark_version       = coalesce(each.value.spark_version, data.databricks_spark_version.lts.id)
  runtime_engine      = coalesce(each.value.runtime_engine, "STANDARD")
  node_type_id        = coalesce(each.value.node_type_id, data.databricks_node_type.smallest.id)
  driver_node_type_id = each.value.driver_node_type_id
  data_security_mode  = coalesce(each.value.data_security_mode, "USER_ISOLATION")
  spark_env_vars      = coalesce(each.value.spark_env_vars, {})
  single_user_name    = each.value.single_user_name
  ssh_public_keys     = each.value.ssh_public_keys

  autoscale {
    min_workers = coalesce(each.value.autoscale_min_workers, 1)
    max_workers = coalesce(each.value.autoscale_max_workers, 1)
  }

  dynamic "init_scripts" {
    for_each = toset([for script in each.value.init_scripts : script.destination if script.type == "volume"])

    content {
      volumes {
        destination = init_scripts.key
      }
    }
  }

  dynamic "init_scripts" {
    for_each = toset([for script in each.value.init_scripts : script.destination if script.type == "workspace"])

    content {
      workspace {
        destination = init_scripts.key
      }
    }
  }

  dynamic "library" {
    for_each = toset([for library in each.value.libraries : library.destination if library.type == "jar"])

    content {
      jar = library.key
    }
  }

  dynamic "library" {
    for_each = toset([for library in each.value.libraries : library.destination if library.type == "whl"])

    content {
      whl = library.key
    }
  }

  aws_attributes {
    instance_profile_arn = each.value.instance_profile_arn
    availability         = coalesce(each.value.availability, "ON_DEMAND")
  }

  autotermination_minutes = coalesce(each.value.autotermination_minutes, 30)
  no_wait                 = each.value.no_wait
  custom_tags             = each.value.custom_tags
}

resource "databricks_permissions" "clusters" {
  for_each   = { for key, value in var.clusters : key => value if length(coalesce(value.permissions, [])) != 0 }
  cluster_id = databricks_cluster.clusters[each.key].id

  dynamic "access_control" {
    for_each = each.value.permissions

    content {
      group_name       = data.databricks_group.clusters[access_control.value.group].display_name
      permission_level = access_control.value.privilege
    }
  }
}

data "databricks_group" "clusters" {
  for_each     = toset(flatten([for key, cluster in var.clusters : [for permission in cluster.permissions : permission.group]]))
  display_name = each.key
}

data "databricks_spark_version" "lts" {
  long_term_support = true
}

data "databricks_node_type" "smallest" {
  local_disk = true
}
