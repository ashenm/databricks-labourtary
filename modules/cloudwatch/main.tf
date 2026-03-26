module "agent" {
  count     = var.agent != null ? 1 : 0
  source    = "./agent"
  artifacts = var.agent.artifacts
}
