variable "agent" {
  type = object({
    artifacts = object({
      volume_path = string
    })
  })
  default = null
}
