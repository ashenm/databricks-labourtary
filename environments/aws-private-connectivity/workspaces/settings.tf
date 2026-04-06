resource "databricks_workspace_setting_v2" "llm_proxy_partner_powered" {
  name        = "llm_proxy_partner_powered"
  boolean_val = { value = true }
}
