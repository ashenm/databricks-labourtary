resource "databricks_recipient" "opensharings" {
  for_each                           = var.recipients
  name                               = coalesce(each.value.name, each.key)
  authentication_type                = each.value.authentication_type
  data_recipient_global_metastore_id = each.value.data_recipient_global_metastore_id
  sharing_code                       = each.value.sharing_code

  dynamic "ip_access_list" {
    for_each = length(each.value.ip_access_list) != 0 ? [1] : []

    content {
      allowed_ip_addresses = each.value.ip_access_list
    }
  }

  properties_kvpairs {
    properties = each.value.properties
  }

  comment = each.value.comment
}

resource "databricks_share" "opensharings" {
  for_each = var.shares
  name     = coalesce(each.value.name, each.key)
  owner    = each.value.owner
  comment  = each.value.comment

  dynamic "object" {
    for_each = each.value.objects

    content {
      name             = object.value.name
      data_object_type = object.value.type
      comment          = object.value.comment

      cdf_enabled                 = each.value.history == "cdf" ? true : null
      history_data_sharing_status = each.value.history == "history" ? "ENABLED" : null

      content = contains([
        "NOTEBOOK_FILE"
      ], object.value.type) ? object.value.content : null

      # applicable only for table-like data objects
      shared_as = contains([
        "FOREIGN_TABLE",
        "MATERIALIZED_VIEW",
        "STREAMING_TABLE",
        "TABLE",
        "VIEW",
      ], object.value.type) ? object.value.alias : null

      # applicable only for non-table data objects
      string_shared_as = contains([
        "FUNCTION",
        "MODEL",
        "NOTEBOOK_FILE",
        "VOLUME",
      ], object.value.type) ? object.value.alias : null
    }
  }
}

resource "databricks_grants" "opensharings" {
  for_each = merge([for key, value in var.shares : { for recipient in value.recipients : join("-", [key, recipient]) => {
    key       = key
    recipient = recipient
  } }]...)
  share = databricks_share.opensharings[each.value.key].name

  grant {
    principal  = databricks_recipient.opensharings[each.value.recipient].name
    privileges = ["SELECT"]
  }
}
