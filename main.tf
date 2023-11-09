data "aws_subnets" "available" {

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["*${var.private_tag_identifier}*"]
  }
}

data "aws_subnet" "private" {
  count = length(data.aws_subnets.available.ids)
  id    = data.aws_subnets.available.ids[count.index]
}

locals {
  ids_sorted_by_az = values(zipmap(data.aws_subnet.private.*.availability_zone, data.aws_subnet.private.*.id))
  # Simple AD requires exactly 2 subnets
  ad_subnets       = slice(local.ids_sorted_by_az, 0, 2)
}

resource "aws_directory_service_directory" "simple_ad" {
  name        = var.directory_fqdn
  short_name  = var.directory_shortname
  password    = var.admin_password
  size        = var.directory_size
  description = var.directory_description

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = local.ad_subnets
  }

  tags = module.this.tags
}

locals {
  dns_ip_addresses = {
    for i in [0, 1] : i => tolist(aws_directory_service_directory.simple_ad.dns_ip_addresses)[i]
  }
}

module "nlb" {
  source                   = "cloudposse/nlb/aws"
  version                  = "0.14.0"
  vpc_id                   = var.vpc_id
  subnet_ids               = data.aws_subnets.available.ids
  internal                 = var.internal
  certificate_arn          = var.nlb_certificate_arn
  tcp_enabled              = true
  tcp_port                 = 389
  tls_enabled              = true
  tls_port                 = 636
  tls_ssl_policy           = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  access_logs_enabled      = false
  target_group_port        = 389
  target_group_target_type = "ip"

  context = module.this.context
}

resource "aws_lb_target_group_attachment" "ad_nlb_attachment" {
  for_each = local.dns_ip_addresses

  target_group_arn = module.nlb.default_target_group_arn
  target_id        = each.value
  port             = 389
}

resource "aws_vpc_dhcp_options" "dns_resolver" {
  domain_name_servers = values(local.dns_ip_addresses)
  domain_name         = var.directory_fqdn
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = var.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.dns_resolver.id
}

# VPC AD ENDPOINT

locals {
  allowed_principals = [for account_id in var.allowed_account_ids: "arn:aws:iam::${account_id}:root"]
}

resource "aws_vpc_endpoint_service" "simplead" {
  acceptance_required        = false
  allowed_principals         = local.allowed_principals
  network_load_balancer_arns = [module.nlb.nlb_arn]
  private_dns_name           = var.private_dns_name
  supported_ip_address_types = ["ipv4"]

  tags = module.this.tags
}

resource "aws_route53_record" "dns_validation" {
  count   = var.private_dns_name_validation ? 1 : 0
  zone_id = var.private_dns_name_zone_id
  name    = join("", aws_vpc_endpoint_service.simplead.private_dns_name_configuration[*].name)
  type    = join("", aws_vpc_endpoint_service.simplead.private_dns_name_configuration[*].type)
  ttl     = 1800
  records = [join("", aws_vpc_endpoint_service.simplead.private_dns_name_configuration[*].value)]
}
