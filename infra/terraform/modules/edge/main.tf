# Módulo edge.
#
# Futuramente este módulo criará:
# - CloudFront
# - WAF
# - ACM em us-east-1
# - integração com ALB
# - Shield Standard como proteção nativa

locals {
  planned_resources = [
    "cloudfront_distribution",
    "waf_web_acl",
    "acm_certificate",
    "alb_origin",
    "shield_standard",
  ]
}
