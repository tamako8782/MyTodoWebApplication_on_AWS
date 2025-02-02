variable "dns_zone_name" {
  description = "DNS zone name for Route53"
  type        = string

}


variable "ecr_repo_name" {
  description = "repository name for ECR"
  type        = string
}


variable "db_username" {
  description = "RDS username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "first database name for RDS"
  type        = string
  sensitive   = true
}

