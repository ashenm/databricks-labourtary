resource "aws_security_group" "databricks" {
  name   = upper("${var.name_prefix}-databricks")
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port   = 0
    self      = true
    protocol  = "-1"
  }

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.main.cidr_block]
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

resource "aws_security_group" "fck-nat" {
  name   = upper("${var.name_prefix}-fck-nat")
  vpc_id = aws_vpc.main.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = upper("${var.name_prefix}-fck-nat") }
}

