resource "databricks_token" "main" {
  lifetime_seconds = 60 * 60
  depends_on       = [databricks_workspace_conf.main]
}

resource "databricks_permissions" "tokens" {
  authorization = "tokens"

  access_control {
    group_name       = "one-env-laboratory-readers"
    permission_level = "CAN_USE"
  }

  depends_on = [databricks_token.main]
}

resource "databricks_directory" "users" {
  path = "/Workspace/Users/hewagallage.gunaratne@databricks.com/.bundles/common"
}

resource "databricks_permissions" "users" {
  directory_path = databricks_directory.users.path

  access_control {
    group_name       = "one-env-laboratory-readers"
    permission_level = "CAN_MANAGE"
  }
}
