locals {
  interfaces = {
    # bastion
    ssm = {
      type      = "Interface"
      namespace = "ssm.${data.aws_region.current.region}.amazonaws.com"
      service   = "${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.region}.ssm"
      provider  = "aws"
      dns       = "custom"
    }
    ssmmessages = {
      type      = "Interface"
      namespace = "ssmmessages.${data.aws_region.current.region}.amazonaws.com"
      service   = "${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.region}.ssmmessages"
      provider  = "aws"
      dns       = "custom"
    }
    ec2messages = {
      type      = "Interface"
      namespace = "ec2messages.${data.aws_region.current.region}.amazonaws.com"
      service   = "${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.region}.ec2messages"
      provider  = "aws"
      dns       = "custom"
    }

    s3 = {
      provider            = "aws"
      namespace           = "s3"
      private_dns_enabled = false
      auxiliaries         = ["s3.${data.aws_region.current.region}.amazonaws.com"]
    }
    sts = {
      provider            = "aws"
      namespace           = "sts"
      private_dns_enabled = false
    }
    kinesis-streams = {
      provider            = "aws"
      namespace           = "kinesis"
      private_dns_enabled = false
    }
    rest = {
      provider = "databricks", service = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-02535b257fc253ff4"
    }
    relay = {
      provider = "databricks", service = "com.amazonaws.vpce.ap-southeast-1.vpce-svc-0557367c6fc1a0c5c"
    }
  }
}

#
# Requires to allow validate the bucket region which uses the global S3 endpoint s3.amazonaws.com
# WARN DatabricksS3LoggingUtils$:V3: Error calling HeadBucket: 400. This is typically used to infer the region of the bucket and is harmless.
#
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.region}.s3"
  route_table_ids   = [aws_route_table.databricks.id]
  vpc_endpoint_type = "Gateway"

  policy = jsonencode({
    Version = "2008-10-17"
    Statement = [
      {
        Effect    = "Deny",
        Principal = "*",
        Action    = "*",
        Resource  = "*"
      }
    ]
  })

  tags = { Name = upper("${var.name_prefix}-s3") }
}

resource "aws_vpc_endpoint" "interfaces" {
  for_each            = local.interfaces
  vpc_id              = aws_vpc.main.id
  private_dns_enabled = lookup(each.value, "private_dns_enabled", true)
  service_name        = data.aws_vpc_endpoint_service.interfaces[each.key].service_name
  subnet_ids          = aws_subnet.privatelink.*.id
  security_group_ids  = [aws_security_group.vpce.id]
  vpc_endpoint_type   = data.aws_vpc_endpoint_service.interfaces[each.key].service_type
  tags                = { Name = upper("${var.name_prefix}-${each.key}") }
}

data "aws_vpc_endpoint_service" "interfaces" {
  for_each     = local.interfaces
  service_type = "Interface"
  service_name = lookup(each.value, "service", "${data.aws_partition.current.reverse_dns_prefix}.${data.aws_region.current.region}.${each.key}")
}
