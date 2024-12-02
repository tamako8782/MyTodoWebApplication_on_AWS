# 1. Route 53 のホストゾーンを作成
resource "aws_route53_zone" "tamako_zone" {
  name = var.dns_zone_name # ドメイン名（例: example.com）を指定
}
# 2. 既存の ALB を取得
data "aws_lb" "tamako_eks_alb" {
  name = "k8s-tamakoap-ingressy-53d16f478f" # ALBの名前を指定
}

# 3. Route 53 レコードを作成
resource "aws_route53_record" "tamako_record" {
  zone_id = aws_route53_zone.tamako_zone.zone_id
  name    = aws_route53_zone.tamako_zone.name
  type    = "A" # ALBの場合はAレコードを指定

  alias {
    name                   = data.aws_lb.tamako_eks_alb.dns_name
    zone_id                = data.aws_lb.tamako_eks_alb.zone_id
    evaluate_target_health = true
  }
}

# 4. 必要に応じて ACM 証明書を追加
resource "aws_acm_certificate" "tamako_cert" {
  domain_name               = aws_route53_zone.tamako_zone.name
  subject_alternative_names = ["*.${aws_route53_zone.tamako_zone.name}"] // サブドメインもネイキッドドメインもすべて保護可能

  validation_method = "DNS"

  tags = {
    Name = "TamakoAppCert"
  }
  // 新しいリソースを作成してから古いリソースを削除する
  lifecycle {
    create_before_destroy = true
  }
}

# 5. ACM 証明書の検証用 DNS レコード
resource "aws_route53_record" "tamako_cert_validation" {
  for_each = {
    //ACM が生成する domain_validation_options のリストからマップを動的に作成
    for dvo in aws_acm_certificate.tamako_cert.domain_validation_options : dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  allow_overwrite = true
  zone_id         = aws_route53_zone.tamako_zone.zone_id
  name            = each.value.name
  type            = each.value.type
  records         = [each.value.value]
  ttl             = 300
}

# 6. ACM 証明書の検証完了を待機
resource "aws_acm_certificate_validation" "tamako_cert_validation" {
  certificate_arn         = aws_acm_certificate.tamako_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.tamako_cert_validation : record.fqdn]
}

