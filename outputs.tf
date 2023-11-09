output "id" {
  value       = aws_directory_service_directory.simple_ad.id
  description = "The directory identifier."
}

output "access_url" {
  value       = aws_directory_service_directory.simple_ad.access_url
  description = "The access URL for the directory, such as http://alias.awsapps.com."
}

output "security_group_id" {
  value       = aws_directory_service_directory.simple_ad.security_group_id
  description = "The ID of the security group created by the directory."
}

output "subnet_ids" {
  value       = local.ad_subnets
  description = "The identifiers of the subnets for the directory servers."
}

output "dns_ip_addresses" {
  value       = aws_directory_service_directory.simple_ad.dns_ip_addresses
  description = "A list of IP addresses of the DNS servers for the directory or connector."
}

output "nlb_dns_name" {
  value       = module.nlb.nlb_dns_name
  description = "DNS name of Network LoadBalancer."
}

output "private_dns_name_configuration_name" {
  value       = var.private_dns_name_validation ? null : join("", aws_vpc_endpoint_service.simplead.private_dns_name_configuration[*].name)
  description = "Name of the TXT record for the endpoint service private DNS name validation."
}

output "private_dns_name_configuration_value" {
  value       = var.private_dns_name_validation ? null : join("", aws_vpc_endpoint_service.simplead.private_dns_name_configuration[*].value)
  description = "Value to set into DNS TXT record for the endpoint service private DNS name validation."
}

output "service_name" {
  value       = aws_vpc_endpoint_service.simplead.service_name
  description = "Service name of the PrivateLink endpoint."
}
