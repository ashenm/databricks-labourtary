resource "aws_subnet" "privatelink" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.privatelink_cidr_block, local.newbits, count.index)
  availability_zone       = element(local.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags                    = { Name = upper("${var.name_prefix}-privatelink-${count.index}") }
}

resource "aws_subnet" "databricks" {
  count                   = 2 * local.databricks_workspaces
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(local.databricks_cidr_block, length(format("%b", 2 * local.databricks_workspaces)), count.index)
  availability_zone       = element(local.availability_zones, count.index % 2)
  map_public_ip_on_launch = false
  tags                    = { Name = upper("${var.name_prefix}-databricks-${floor(count.index / 2) + 1}") }
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

data "aws_prefix_list" "s3" {
  name = "com.amazonaws.ap-southeast-1.s3"
}
