resource "aws_security_group" "databricks" {
  name   = upper("${var.name_prefix}-databricks")
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port   = 0
    self      = true
    protocol  = "-1"
  }

  egress {
    from_port = 0
    to_port   = 0
    self      = true
    protocol  = "-1"
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [local.cidr_block]
    ipv6_cidr_blocks = []
  }

  ingress {
    from_port        = 6666
    to_port          = 6666
    protocol         = "tcp"
    cidr_blocks      = [local.cidr_block]
    ipv6_cidr_blocks = []
  }

  ingress {
    from_port        = 2443
    to_port          = 2443
    protocol         = "tcp"
    cidr_blocks      = [local.cidr_block]
    ipv6_cidr_blocks = []
  }

  ingress {
    from_port        = 8443
    to_port          = 8443
    protocol         = "tcp"
    cidr_blocks      = [local.cidr_block]
    ipv6_cidr_blocks = []
  }

  ingress {
    from_port        = 8444
    to_port          = 8444
    protocol         = "tcp"
    cidr_blocks      = [local.cidr_block]
    ipv6_cidr_blocks = []
  }

  ingress {
    from_port        = 8445
    to_port          = 8451
    protocol         = "tcp"
    cidr_blocks      = [local.cidr_block]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = upper("${var.name_prefix}-databricks") }
}

resource "aws_security_group" "vpce" {
  name   = upper("${var.name_prefix}-vpce")
  vpc_id = aws_vpc.main.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = []
  }

  tags = { Name = upper("${var.name_prefix}-vpce") }
}
