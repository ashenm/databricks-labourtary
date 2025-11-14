resource "aws_cloudwatch_log_group" "vpc" {
  name = "/aws/vpc/${upper(var.name_prefix)}"
}
