output "recipients" {
  value = { for key, value in var.recipients : key => {
    id     = databricks_recipient.opensharings[key].id
    name   = databricks_recipient.opensharings[key].name
    cloud  = databricks_recipient.opensharings[key].cloud
    region = databricks_recipient.opensharings[key].region
  } }
}

output "shares" {
  value = { for key, value in var.shares : key => {
    id   = databricks_share.opensharings[key].id
    name = databricks_share.opensharings[key].name
  } }
}
