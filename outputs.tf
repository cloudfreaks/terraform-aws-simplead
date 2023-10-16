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
  value       = random_shuffle.az.result
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
