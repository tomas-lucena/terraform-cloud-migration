resource "aws_route53_record" "database_postgres" {
  zone_id = var.domain_zone_id
  name    = "database-postgres.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [var.database_address]
}

resource "aws_route53_record" "alb" {
  zone_id = var.domain_zone_id
  name    = "app.${var.domain}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
