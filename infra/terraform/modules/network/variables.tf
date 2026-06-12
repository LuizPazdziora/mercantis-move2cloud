variable "project_name" {
  description = "Nome técnico do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente lógico da infraestrutura."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC."
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) >= 2
    error_message = "Informe pelo menos duas subnets públicas."
  }
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs das subnets privadas de aplicação."
  type        = list(string)

  validation {
    condition     = length(var.private_app_subnet_cidrs) >= 2
    error_message = "Informe pelo menos duas subnets privadas de aplicação."
  }
}

variable "private_db_subnet_cidrs" {
  description = "CIDRs das subnets privadas de banco."
  type        = list(string)

  validation {
    condition     = length(var.private_db_subnet_cidrs) >= 2
    error_message = "Informe pelo menos duas subnets privadas de banco."
  }
}

variable "common_tags" {
  description = "Tags comuns aplicadas aos recursos."
  type        = map(string)
}
