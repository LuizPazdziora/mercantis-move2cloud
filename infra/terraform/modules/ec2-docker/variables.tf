variable "project_name" {
  description = "Nome técnico do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente lógico da infraestrutura."
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet privada de aplicação onde a EC2 será criada."
  type        = string
}

variable "security_group_id" {
  description = "ID do security group da EC2 de aplicação."
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Nome opcional de key pair para SSH restrito. Padrão nulo."
  type        = string
  default     = null
}

variable "root_volume_size" {
  description = "Tamanho do volume raiz da EC2 em GiB."
  type        = number
  default     = 20
}

variable "repository_url" {
  description = "URL do repositório Git público a ser clonado na EC2."
  type        = string
}

variable "repository_branch" {
  description = "Branch do repositório a ser implantada na EC2."
  type        = string
  default     = "main"
}

variable "db_host" {
  description = "Endpoint DNS do RDS MariaDB."
  type        = string

  validation {
    condition     = length(regexall(":", var.db_host)) == 0
    error_message = "Informe DB_HOST apenas com o host do RDS, sem porta."
  }
}

variable "db_port" {
  description = "Porta do RDS MariaDB."
  type        = number
  default     = 3306
}

variable "db_name" {
  description = "Nome do banco de dados."
  type        = string
}

variable "db_user" {
  description = "Usuário do banco de dados."
  type        = string
}

variable "db_password" {
  description = "Senha do banco de dados. Valor sensível, não versionar em tfvars real."
  type        = string
  sensitive   = true

  validation {
    condition = (
      length(trimspace(var.db_password)) >= 12 &&
      !contains(["altere_esta_senha_fora_do_git", "change_me", "password", "senha"], lower(trimspace(var.db_password)))
    )
    error_message = "db_password deve ser uma senha real de desenvolvimento, informada em dev.tfvars local e nunca versionada. Nao use vazio, placeholder, CHANGE_ME, password ou senha."
  }
}

variable "allowed_origins" {
  description = "Origens CORS permitidas para o backend."
  type        = string
  default     = "*"
}

variable "common_tags" {
  description = "Tags comuns aplicadas aos recursos."
  type        = map(string)
}
