resource "aws_route53_record" "tamako_record" {
  zone_id = data.terraform_remote_state.general.outputs.dns_zone_id
  name    = data.terraform_remote_state.general.outputs.dns_zone_name
  type    = "A"

  alias {
    name                   = resource.aws_lb.tamako_alb.dns_name
    zone_id                = resource.aws_lb.tamako_alb.zone_id
    evaluate_target_health = true
  }
}


resource "aws_acm_certificate" "tamako_cert" {
  domain_name               = data.terraform_remote_state.general.outputs.dns_zone_name
  subject_alternative_names = ["*.${data.terraform_remote_state.general.outputs.dns_zone_name}"]

  validation_method = "DNS"

  tags = {
    Name = "TamakoAppCert"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "tamako_cert_validation" {
  for_each = {

    for dvo in aws_acm_certificate.tamako_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = data.terraform_remote_state.general.outputs.dns_zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.value]
  ttl             = 300
}


resource "aws_acm_certificate_validation" "tamako_cert_validation" {
  certificate_arn         = aws_acm_certificate.tamako_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.tamako_cert_validation : record.fqdn]
}

