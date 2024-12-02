// global configuration
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

// DNS zone name for Route53
variable "dns_zone_name" {
  description = "DNS zone name"
  type        = string

}


