resource "databricks_sql_endpoint" "starter_warehouse" {
  name                      = "Workspace Starter Warehouse"
  cluster_size              = "Small"
  warehouse_type            = "PRO"
  min_num_clusters          = 1
  max_num_clusters          = 1
  auto_stop_mins            = 60
  enable_serverless_compute = true
  no_wait                   = true
}

resource "databricks_permissions" "starter_warehouse" {
  sql_endpoint_id = databricks_sql_endpoint.starter_warehouse.id

  dynamic "access_control" {
    for_each = local.sql_starter_warehouse_acls

    content {
      permission_level       = access_control.value.permission_level
      group_name             = lookup(access_control.value, "group_name", null)
      service_principal_name = lookup(access_control.value, "service_principal_name", null)
      user_name              = lookup(access_control.value, "user_name", null)
    }
  }
}

data "external" "starter_warehouse_permissions" {
  program = ["python3", "${path.module}/externals/get-sql-warehouse-permissions.py"]
  query = {
    host             = data.databricks_current_user.current.workspace_url
    sql_warehouse_id = databricks_sql_endpoint.starter_warehouse.id
    permissions = jsonencode([
      {
        group_name       = "one-env-laboratory-sudoers"
        permission_level = "CAN_MANAGE"
      },
      {
        group_name       = "users",
        permission_level = "CAN_MANAGE"
      }
    ])
  }
}
