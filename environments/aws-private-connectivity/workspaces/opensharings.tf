module "opensharings" {
  source     = "../../../modules/opensharings"
  recipients = lookup(local.configs, "recipients", {})
  shares     = lookup(local.configs, "shares", {})
}
