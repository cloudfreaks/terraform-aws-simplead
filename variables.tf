variable "vpc_id" {
  type        = string
  description = "(Required) The identifier of the VPC that the directory is in."
}

variable "directory_subnet_ids" {
  type        = list(string)
  description = "(Optional) The identifiers of the PRIVATE subnets for the directory servers (this module will select 2 subnets out of the list provided if > 2)."
  default     = []
}

variable "nlb_subnet_ids" {
  type        = list(string)
  description = "(Optional) The identifiers of the subnets for the Network Load Balancer. These can be public, if the directory should be exposed to internet, or private if the NLB is used only internally as single endpoint for the directory. If undefined, this will be deployed into the same subnets as the directory."
  default     = []
}

variable "private_tag_identifier" {
  type        = string
  description = "(Optional) This is an attempt to search and set the private subnets to the directory. The tag identifier is a string included in your subnets Tag:Name that's idenitying it as internal, or private, and it need to perfectly match that bit of a tag. By default this sets 'private', which - for example - will match a subnet name like 'sub-euw1-private-a'"
  default     = "private"
}

variable "directory_fqdn" {
  type        = string
  description = "(Required) The fully qualified name for the directory, such as corp.example.com."
}

variable "directory_shortname" {
  type        = string
  description = "(Optional) The short name (NetBIOS) of the directory, such as CORP."
}

variable "directory_description" {
  type        = string
  description = "(Optional) A textual description for the directory."
  default     = null
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "(Required) The password for the directory administrator."
}

variable "directory_size" {
  type        = string
  description = "(Optional) The size of the directory (`Small` or `Large` are accepted values). `Small` by default."
  default     = "Small"
}

variable "internal" {
  type        = bool
  description = "A boolean flag to determine whether the ALB which will target the LDAP server should be internal."
  default     = false
}
