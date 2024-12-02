output "name_servers" {
  description = "A list of name servers in associated (or default) delegation set."
  value       = aws_route53_zone.tamako_zone.name_servers
}

# 7. 出力
output "alb_dns_name" {
  value = data.aws_lb.tamako_eks_alb.dns_name
}

output "route53_zone_id" {
  value = aws_route53_zone.tamako_zone.zone_id
}

output "certificate_arn" {
  value = aws_acm_certificate.tamako_cert.arn
}
