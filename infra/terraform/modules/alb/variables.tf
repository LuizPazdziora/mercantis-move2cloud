variable "project_name" {
  description = "Nome técnico do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente lógico da infraestrutura."
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "IDs das subnets públicas onde o ALB será criado."
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID do security group do ALB."
  type        = string
}

variable "target_instance_id" {
  description = "ID da instância EC2 privada registrada no target group."
  type        = string
}

variable "target_port" {
  description = "Porta da aplicação na EC2. O frontend Nginx escuta na porta 80."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Variável mantida por compatibilidade. O Target Group do frontend usa health check fixo em /."
  type        = string
  default     = "/"
}

variable "enable_deletion_protection" {
  description = "Proteção contra exclusão do ALB."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Tags comuns aplicadas aos recursos."
  type        = map(string)
}
