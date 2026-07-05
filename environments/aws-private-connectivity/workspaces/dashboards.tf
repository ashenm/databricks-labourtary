resource "databricks_dashboard" "main" {
  display_name         = "Voyager"
  warehouse_id         = module.warehouses.warehouses["common"].id
  serialized_dashboard = "{\"pages\":[{\"name\":\"voyager\",\"displayName\":\"Voyager\"}]}"
  embed_credentials    = false
  parent_path          = "/Shared/Dashboards"
}

resource "databricks_permissions" "main" {
  dashboard_id = databricks_dashboard.main.id

  access_control {
    group_name       = data.databricks_group.readers.display_name
    permission_level = "CAN_RUN"
  }

  access_control {
    group_name       = data.databricks_group.sudoers.display_name
    permission_level = "CAN_MANAGE"
  }
}
