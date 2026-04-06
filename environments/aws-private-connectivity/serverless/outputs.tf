output "network_connectivity_config_id" {
  value = databricks_mws_network_connectivity_config.main.id
}

output "network_connectivity_config_egress_config" {
  value = databricks_mws_network_connectivity_config.main.egress_config
}
