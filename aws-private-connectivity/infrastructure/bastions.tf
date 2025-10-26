resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.bastion.id
  instance_type        = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  root_block_device {
    encrypted = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  primary_network_interface {
    network_interface_id = aws_network_interface.bastion.id
  }

  tags = {
    Name = upper("${var.name_prefix}-bastion")
  }
}

resource "aws_network_interface" "bastion" {
  subnet_id       = element(aws_subnet.databricks.*.id, 0)
  security_groups = [aws_security_group.bastion.id]
  tags            = { Name = upper("${var.name_prefix}-bastion") }
}

resource "aws_security_group" "bastion" {
  name   = upper("${var.name_prefix}-bastion")
  vpc_id = aws_vpc.main.id

  egress {
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    protocol         = "-1"
  }

  tags = { Name = upper("${var.name_prefix}-bastion") }
}

resource "aws_iam_role" "bastion" {
  name               = upper("${var.name_prefix}-bastion")
  assume_role_policy = data.aws_iam_policy_document.ec2.json
}

resource "aws_iam_role_policy_attachment" "bastion" {
  role       = aws_iam_role.bastion.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_instance_profile" "bastion" {
  name = upper("${var.name_prefix}-bastion")
  role = aws_iam_role.bastion.name
}

data "aws_iam_policy_document" "ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    effect = "Allow"
  }
}

data "aws_iam_policy" "ssm" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_ami" "bastion" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}
