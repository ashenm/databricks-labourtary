variable "recipients" {
  type = map(object({
    name                               = optional(string)
    comment                            = optional(string)
    authentication_type                = optional(string, "DATABRICKS")
    data_recipient_global_metastore_id = optional(string)
    sharing_code                       = optional(string)
    ip_access_list                     = optional(list(string), [])
    properties                         = optional(map(string), {})
  }))
}

variable "shares" {
  type = map(object({
    name    = optional(string)
    owner   = optional(string)
    comment = optional(string)
    objects = optional(map(object({
      name       = string
      type       = string # https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/share#object-configuration-block
      alias      = optional(string)
      comment    = optional(string)
      content    = optional(string)
      versioning = optional(string, "none") # none, cdf, history
    })), {})
    recipients = optional(list(string), [])
  }))
}
