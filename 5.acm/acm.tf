resource "aws_acm_certificate" "cert" {
  domain_name       = "app.nextzen.tech"
  validation_method = "DNS"


  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "subdomain_cert" {
  # for_each = {
  #   for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
  #     name   = dvo.resource_record_name
  #     record = dvo.resource_record_value
  #     type   = dvo.resource_record_type
  #   }
  # }

  allow_overwrite = true
  zone_id = var.domain_zone_id
  # name    = each.value.name
  # type    = each.value.type
  # records = [each.value.record]
  name            = aws_acm_certificate.cert.domain_validation_options.*.resource_record_name[0]
  records         = [aws_acm_certificate.cert.domain_validation_options.*.resource_record_value[0]]
  type            = aws_acm_certificate.cert.domain_validation_options.*.resource_record_type[0]
  ttl     = 60

  depends_on = [ aws_acm_certificate.cert ]
}


resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.subdomain_cert.fqdn]
}
