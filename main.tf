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

resource "random_shuffle" "az" {
  input        = length(var.directory_subnet_ids) >= 2 ? var.directory_subnet_ids : data.aws_subnets.available.ids
  result_count = 2
}

resource "aws_directory_service_directory" "simple_ad" {
  name        = var.directory_fqdn
  short_name  = var.directory_shortname
  password    = var.admin_password
  size        = var.directory_size
  description = var.directory_description

  vpc_settings {
    vpc_id     = var.vpc_id
    subnet_ids = random_shuffle.az.result
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
  subnet_ids               = length(var.nlb_subnet_ids) >= 2 ? var.nlb_subnet_ids : random_shuffle.az.result
  internal                 = var.internal
  tcp_enabled              = true
  tcp_port                 = 389
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
