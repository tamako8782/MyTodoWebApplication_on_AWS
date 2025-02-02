output "alb_dns_name" {
  value = resource.aws_lb.tamako_alb.dns_name
}

output "route53_zone_id" {
  value = data.terraform_remote_state.general.outputs.dns_zone_id
}

output "certificate_arn" {
  value = resource.aws_acm_certificate.tamako_cert.arn
}

output "alb_target_group_arn" {
  value = resource.aws_lb_target_group.tamako_alb_tg.arn
}
