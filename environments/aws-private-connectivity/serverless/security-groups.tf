resource "aws_security_group" "nlb" {
  name   = upper("${var.name_prefix}-nlb")
  vpc_id = local.aws_vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = upper("${var.name_prefix}-nlb") }
}

resource "aws_security_group" "alb" {
  name   = upper("${var.name_prefix}-alb")
  vpc_id = local.aws_vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.nlb.id]
  }

  tags = { Name = upper("${var.name_prefix}-alb") }
}
