variable "name_prefix" {
  type    = string
  default = null
}

variable "clusters" {
  type = map(object({
    name                    = optional(string)
    availability            = optional(string)
    node_type_id            = optional(string)
    data_security_mode      = optional(string)
    single_user_name        = optional(string)
    driver_node_type_id     = optional(string)
    num_workers             = optional(string)
    runtime_engine          = optional(string)
    spark_conf              = optional(map(string))
    spark_version           = optional(string)
    spark_env_vars          = optional(map(string))
    autotermination_minutes = optional(number)
    autoscale_min_workers   = optional(number)
    autoscale_max_workers   = optional(number)
    custom_tags             = optional(map(string))
    no_wait                 = optional(bool)
    instance_profile_arn    = optional(string)
    ssh_public_keys         = optional(list(string))

    # set below to prevent automation cleanup due to inactivity
    # https://docs.databricks.com/aws/en/compute/clusters-manage#terminate-a-compute
    is_pinned = optional(bool, true)

    init_scripts = optional(list(object({
      type        = string # s3, volume, or workspace
      destination = string
    })), [])
    libraries = optional(list(object({
      type        = string
      destination = string
    })), [])
    permissions = optional(list(object({
      group     = string
      privilege = string
    })), [])
  }))
}
