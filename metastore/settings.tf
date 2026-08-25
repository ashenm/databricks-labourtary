# Outbound (serverless) AWS Private Link to AWS-managed resources
resource "databricks_account_setting_v2" "serverless_1p_pl" {
  name = "serverless_1p_pl"

  boolean_val = {
    value = true
  }
}
