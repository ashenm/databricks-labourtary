variable "name_prefix" {
  type    = string
  default = null
}

variable "warehouses" {
  type = map(object({
    name                      = optional(string)
    size                      = optional(string, "Small")
    min_num_clusters          = optional(number, 1)
    max_num_clusters          = optional(number, 1)
    auto_stop_mins            = optional(number, 30)
    spot_instance_policy      = optional(string, "RELIABILITY_OPTIMIZED")
    enable_serverless_compute = optional(bool, false)
    channel                   = optional(string, "CHANNEL_NAME_CURRENT")
    type                      = optional(string, "PRO")
    no_wait                   = optional(bool)
    custom_tags               = optional(map(string), {})
  }))
}
