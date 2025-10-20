locals {
  cidr_block = "10.0.0.0/16"

  availability_zone_redundancy = 3

  availability_zones = slice(sort(data.aws_availability_zones.available_zones.names), 0, local.availability_zone_redundancy)
  newbits            = length(format("%b", length(local.availability_zones)))

  private_cidr_block    = cidrsubnet(local.cidr_block, 2, 0)
  nat_cidr_block        = cidrsubnet(local.cidr_block, 2, 1)
  databricks_cidr_block = cidrsubnet(local.cidr_block, 2, 2)
  public_cidr_block     = cidrsubnet(local.cidr_block, 2, 3)
}

resource "aws_vpc" "main" {
  cidr_block           = local.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = upper(var.name_prefix) }
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}
