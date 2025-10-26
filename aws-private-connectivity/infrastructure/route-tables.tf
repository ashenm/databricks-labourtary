resource "aws_route_table" "privatelink" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = upper("${var.name_prefix}-privatelink") }
}

resource "aws_route_table" "databricks" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = upper("${var.name_prefix}-databricks") }
}

resource "aws_route_table" "dmz" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = upper("${var.name_prefix}-dmz") }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = upper("${var.name_prefix}-public") }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.privatelink)
  subnet_id      = element(aws_subnet.privatelink.*.id, count.index)
  route_table_id = aws_route_table.privatelink.id
}

resource "aws_route_table_association" "databricks" {
  count          = length(aws_subnet.databricks)
  subnet_id      = element(aws_subnet.databricks.*.id, count.index)
  route_table_id = aws_route_table.databricks.id
}

resource "aws_route_table_association" "dmz" {
  count          = length(aws_subnet.dmz)
  subnet_id      = element(aws_subnet.dmz.*.id, count.index)
  route_table_id = aws_route_table.dmz.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
