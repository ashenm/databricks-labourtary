resource "aws_subnet" "private" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.private_cidr_block, local.newbits, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags                    = { Name = upper("${var.name_prefix}-private-${count.index}") }
}

resource "aws_subnet" "nat" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.nat_cidr_block, local.newbits, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags                    = { Name = upper("${var.name_prefix}-nat-${count.index}") }
}

resource "aws_subnet" "databricks" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.databricks_cidr_block, local.newbits, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = upper("${var.name_prefix}-databricks-${count.index}") }
}

resource "aws_subnet" "public" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.public_cidr_block, local.newbits, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags                    = { Name = upper("${var.name_prefix}-public-${count.index}") }
}
