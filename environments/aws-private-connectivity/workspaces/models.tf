resource "databricks_ai_gateway_model_service" "whitelist_models" {
  for_each         = toset(jsondecode(data.external.whitelist_models.result.models))
  parent           = "schemas/${module.schemas.schemas["ai"].id}"
  model_service_id = each.key

  config = {
    routing = {
      destinations = [
        {
          name               = "primary"
          destination_type   = "DESTINATION_TYPE_PAY_PER_TOKEN_FOUNDATION_MODEL"
          traffic_percentage = 100
          pay_per_token_config = {
            model = "models/system.ai.${each.key}"
          }
        }
      ]
    }
  }
}


data "external" "whitelist_models" {
  program = ["python3", "${path.module}/../../../externals/get-whitelist-models.py"]

  query = {
    host = data.databricks_current_user.current.workspace_url
  }
}
