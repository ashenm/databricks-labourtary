resource "aws_subnet" "privatelink" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.privatelink_cidr_block, local.newbits, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags                    = { Name = upper("${var.name_prefix}-privatelink-${count.index}") }
}

resource "aws_subnet" "databricks" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.databricks_cidr_block, local.newbits, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags                    = { Name = upper("${var.name_prefix}-databricks-${count.index}") }
}

resource "aws_subnet" "dmz" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.dmz_cidr_block, local.newbits, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = upper("${var.name_prefix}-dmz-${count.index}") }
}

resource "aws_subnet" "public" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.public_cidr_block, local.newbits, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = upper("${var.name_prefix}-public-${count.index}") }
}

resource "aws_network_acl" "main" {
  vpc_id = aws_vpc.main.id

  ingress {
    action     = "allow"
    rule_no    = 100
    from_port  = 0
    to_port    = 0
    cidr_block = local.cidr_block
    protocol   = "-1"
  }

  egress {
    action     = "allow"
    rule_no    = 100
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_block = local.cidr_block
  }

  dynamic "ingress" {
    for_each = range(length(data.aws_prefix_list.s3.cidr_blocks))

    content {
      action     = "allow"
      rule_no    = 107 + ingress.key
      from_port  = 1024
      to_port    = 65535
      protocol   = "tcp"
      cidr_block = element(data.aws_prefix_list.s3.cidr_blocks, ingress.key)
    }
  }

  dynamic "egress" {
    for_each = range(length(data.aws_prefix_list.s3.cidr_blocks))

    content {
      action     = "allow"
      rule_no    = 101 + egress.key
      from_port  = 443
      to_port    = 443
      protocol   = "tcp"
      cidr_block = element(data.aws_prefix_list.s3.cidr_blocks, egress.key)
    }
  }

  tags = { Name = upper(var.name_prefix) }
}

resource "aws_network_acl_association" "databricks" {
  count          = length(aws_subnet.databricks)
  subnet_id      = element(aws_subnet.databricks.*.id, count.index)
  network_acl_id = aws_network_acl.main.id
}

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.ap-southeast-1.s3"
}
