variable "project_name" {
  description = "Nome técnico do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente lógico."
  type        = string
}

variable "alb_dns_name" {
  description = "DNS do ALB usado como origem futura do CloudFront."
  type        = string
}

variable "domain_name" {
  description = "Domínio futuro da aplicação, se aprovado."
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Tags comuns para recursos futuros."
  type        = map(string)
}
