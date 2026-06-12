variable "project_name" {
  description = "Nome técnico do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente lógico da infraestrutura."
  type        = string
}

variable "private_db_subnet_ids" {
  description = "IDs das subnets privadas de banco."
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "ID do security group do RDS."
  type        = string
}

variable "db_name" {
  description = "Nome do banco de dados da aplicação."
  type        = string
}

variable "db_username" {
  description = "Usuário administrador da aplicação no RDS."
  type        = string
}

variable "db_password" {
  description = "Senha do banco RDS. Deve ser informada em tfvars local ou secret externo."
  type        = string
  sensitive   = true
}

variable "db_port" {
  description = "Porta do MariaDB no RDS."
  type        = number
  default     = 3306
}

variable "engine_version" {
  description = "Versão do engine MariaDB. Quando nulo, a AWS escolhe a versão padrão suportada."
  type        = string
  default     = null
}

variable "instance_class" {
  description = "Classe da instância RDS."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Armazenamento inicial em GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Limite de autoscaling de armazenamento em GiB."
  type        = number
  default     = 50
}

variable "backup_retention_period" {
  description = "Retenção de backups automáticos em dias."
  type        = number
  default     = 1
}

variable "backup_window" {
  description = "Janela preferencial de backup em UTC."
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "Janela preferencial de manutenção em UTC."
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "multi_az" {
  description = "Habilita Multi-AZ no RDS."
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Aplica alterações imediatamente no ambiente dev."
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Ignora snapshot final ao destruir o RDS. Padrão adequado apenas para dev."
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Proteção contra exclusão do RDS."
  type        = bool
  default     = false
}

variable "common_tags" {
  description = "Tags comuns aplicadas aos recursos."
  type        = map(string)
}
