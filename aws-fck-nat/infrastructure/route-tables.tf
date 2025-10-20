resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = upper("${var.name_prefix}-PRIVATE") }
}

resource "aws_route_table" "nat" {
  count  = length(local.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.fck-nat[count.index].primary_network_interface_id
  }

  tags = { Name = upper("${var.name_prefix}-NAT-${count.index}") }
}

resource "aws_route_table" "databricks" {
  count  = length(local.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block           = "0.0.0.0/0"
    network_interface_id = aws_instance.fck-nat[count.index].primary_network_interface_id
  }

  tags = { Name = upper("${var.name_prefix}-DATABRICKS-${count.index}") }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = upper("${var.name_prefix}-PUBLIC")
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "nat" {
  count          = length(aws_subnet.nat)
  subnet_id      = element(aws_subnet.nat.*.id, count.index)
  route_table_id = element(aws_route_table.nat.*.id, count.index)
}

resource "aws_route_table_association" "databricks" {
  count          = length(aws_subnet.databricks)
  subnet_id      = element(aws_subnet.databricks.*.id, count.index)
  route_table_id = element(aws_route_table.databricks.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
