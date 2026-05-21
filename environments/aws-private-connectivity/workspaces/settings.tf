resource "databricks_workspace_setting_v2" "llm_proxy_partner_powered" {
  name        = "llm_proxy_partner_powered"
  boolean_val = { value = true }
}

resource "databricks_workspace_setting_v2" "genie_deep_research" {
  name        = "genie_deep_research"
  boolean_val = { value = true }
}

resource "databricks_ip_access_list" "main" {
  label        = "DEFAULT"
  list_type    = "ALLOW"
  enabled      = true
  ip_addresses = ["130.41.0.0/16"]
}
