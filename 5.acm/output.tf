output "domain_cert_arn" {
  value = aws_acm_certificate_validation.validation.certificate_arn
}