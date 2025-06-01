output "dns_zone_name" {
  value       = aws_route53_zone.tamako_zone.name
  description = "DNS zone name"

}

output "dns_zone_id" {
  value       = aws_route53_zone.tamako_zone.zone_id
  description = "DNS zone id"
}

output "ecr_repo_url" {
  value       = aws_ecr_repository.tamako_ecr.repository_url
  description = "ECR repository url"
}


output "secretsmanager_secret_arn" {
  value       = aws_secretsmanager_secret.tamako_db_info.arn
  description = "SecretsManager secret ARN"
}

