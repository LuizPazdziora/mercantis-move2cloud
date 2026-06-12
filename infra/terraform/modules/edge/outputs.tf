output "planned_resources" {
  description = "Recursos planejados para o módulo Edge."
  value       = local.planned_resources
}

# Outputs futuros:
# - cloudfront_domain_name
# - waf_web_acl_arn
# - acm_certificate_arn
