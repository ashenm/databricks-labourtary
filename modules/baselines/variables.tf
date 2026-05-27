variable "cluster_policies" {
  type    = list(string)
  default = ["user", "team"]

  validation {
    condition     = alltrue([for value in var.cluster_policies : contains(["user", "team"], value)])
    error_message = "cluster_policies must be a combination of values 'user' and 'team'"
  }
}
