variable "name_prefix" {
  type    = string
  default = null
}

variable "catalogs" {
  type = map(object({
    name          = optional(string)
    storage_root  = optional(string)
    force_destroy = optional(bool)
    permissions = optional(list(object({
      group      = string
      privileges = list(string)
    })))
    owner = optional(string, null)
  }))
}
