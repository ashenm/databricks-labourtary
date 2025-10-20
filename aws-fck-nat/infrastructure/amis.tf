data "aws_ami" "fck-nat" {
  most_recent = true

  filter {
    name   = "name"
    values = ["fck-nat-al2023-*"]
  }

  owners = ["568608671756"]
}
