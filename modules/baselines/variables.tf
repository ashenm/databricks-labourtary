variable "cluster_policies" {
  type    = list(string)
  default = ["user", "team"]

  validation {
    condition     = alltrue([for value in var.cluster_policies : contains(["user", "team"], value)])
    error_message = "cluster_policies must be a combination of values 'user' and 'team'"
  }
}

variable "drivers" {
  type    = list(string)
  default = ["jar/ojdbc11-23.26.2.0.0.jar"]
}

variable "owner" {
  type    = string
  default = "one-env-laboratory-sudoers"
}

variable "volume_path" {
  type = string
}
