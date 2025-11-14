resource "aws_route53_zone" "aws" {
  for_each = { for k, v in local.interfaces : k => v if v.provider == "aws" && lookup(v, "dns", null) != "aws" }
  name     = "${each.value.namespace}.${data.aws_region.current.region}.amazonaws.com"

  vpc {
    vpc_id = aws_vpc.main.id
  }
}

resource "aws_route53_record" "aws" {
  for_each = { for k, v in local.interfaces : k => v if v.provider == "aws" && lookup(v, "dns", null) != "aws" }
  zone_id  = aws_route53_zone.aws[each.key].id
  name     = data.aws_vpc_endpoint_service.interfaces[each.key].private_dns_name
  type     = "A"

  alias {
    name                   = element(aws_vpc_endpoint.interfaces[each.key].dns_entry, 0).dns_name
    zone_id                = element(aws_vpc_endpoint.interfaces[each.key].dns_entry, 0).hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "aws_auxiliary" {
  for_each = merge([for key, value in local.interfaces : { for dns in lookup(value, "auxiliaries", []) : join("-", [key, dns]) => { dns = dns, key = key } }]...)
  zone_id  = aws_route53_zone.aws[each.value.key].id
  name     = each.value.dns
  type     = "A"

  alias {
    name                   = element(aws_vpc_endpoint.interfaces[each.value.key].dns_entry, 0).dns_name
    zone_id                = element(aws_vpc_endpoint.interfaces[each.value.key].dns_entry, 0).hosted_zone_id
    evaluate_target_health = false
  }
}
