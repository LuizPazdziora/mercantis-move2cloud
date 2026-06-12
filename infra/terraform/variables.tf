variable "project_name" {
  description = "Nome técnico do projeto."
  type        = string
  default     = "mercantis-move2cloud"
}

variable "environment" {
  description = "Ambiente lógico da infraestrutura."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Região principal da AWS para a infraestrutura."
  type        = string
  default     = "sa-east-1"
}

variable "aws_region_edge" {
  description = "Região usada para recursos globais de borda, como ACM para CloudFront."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "Bloco CIDR planejado para a VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "common_tags" {
  description = "Tags comuns aplicadas futuramente aos recursos AWS."
  type        = map(string)
  default = {
    Project     = "Mercantis Move2Cloud"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
