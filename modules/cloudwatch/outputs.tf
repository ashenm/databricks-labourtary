output "agent" {
  value = var.agent != null ? one(module.agent) : null
}
