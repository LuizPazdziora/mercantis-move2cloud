variable "project_name" {
  description = "Nome técnico do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente lógico da infraestrutura."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde os security groups serão criados."
  type        = string
}

variable "alb_ingress_cidrs" {
  description = "CIDRs autorizados a acessar o ALB em HTTP/HTTPS."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_https_ingress" {
  description = "Habilita a entrada 443 no SG do ALB para evolução futura com ACM."
  type        = bool
  default     = false
}

variable "app_port" {
  description = "Porta exposta pela aplicação na EC2 para o ALB."
  type        = number
  default     = 80
}

variable "db_port" {
  description = "Porta interna do MariaDB no RDS."
  type        = number
  default     = 3306
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs opcionais para SSH. Por padrão, SSH não é aberto."
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Tags comuns aplicadas aos recursos."
  type        = map(string)
}
