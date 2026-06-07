resource "databricks_group" "sudoers" {
  display_name = lower("${var.metastore_name}-sudoers")
}

resource "databricks_group" "readers" {
  display_name = lower("${var.metastore_name}-readers")
}

resource "databricks_group_member" "sudoer" {
  group_id  = databricks_group.sudoers.id
  member_id = data.databricks_user.sudoer.id
}

resource "databricks_group_member" "readers" {
  group_id  = databricks_group.readers.id
  member_id = data.databricks_user.sudoer.id
}

resource "databricks_group_member" "service_principal" {
  group_id  = databricks_group.sudoers.id
  member_id = data.external.service_principal.result.id
}

data "databricks_user" "sudoer" {
  user_name = "hewagallage.gunaratne@databricks.com"
}
