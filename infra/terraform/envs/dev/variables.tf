variable "project_name" {
  description = "Nome técnico do projeto."
  type        = string
  default     = "mercantis-move2cloud"
}

variable "environment" {
  description = "Ambiente lógico."
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Região principal para o ambiente dev."
  type        = string
  default     = "sa-east-1"
}

variable "aws_region_edge" {
  description = "Região reservada para recursos de borda em etapa futura."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR da VPC do ambiente dev."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDRs das subnets públicas."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs das subnets privadas de aplicação."
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "private_db_subnet_cidrs" {
  description = "CIDRs das subnets privadas de banco."
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24"]
}

variable "alb_ingress_cidrs" {
  description = "CIDRs autorizados a acessar o ALB em HTTP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_https_ingress" {
  description = "Prepara entrada 443 no SG do ALB para uso futuro com ACM."
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "CIDRs opcionais para SSH restrito. Manter vazio por padrão."
  type        = list(string)
  default     = []
}

variable "app_port" {
  description = "Porta do frontend Nginx na EC2."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Variável mantida por compatibilidade. O Target Group do frontend usa health check fixo em /."
  type        = string
  default     = "/"
}

variable "db_name" {
  description = "Nome do banco de dados no RDS."
  type        = string
  default     = "mercantis"
}

variable "db_username" {
  description = "Usuário do banco RDS. Usar nome compatível com RDS, sem underscore."
  type        = string
  default     = "mercantisapp"
}

variable "db_password" {
  description = "Senha do banco RDS. Informar apenas em dev.tfvars local ou variável segura."
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

variable "db_port" {
  description = "Porta interna do MariaDB no RDS."
  type        = number
  default     = 3306
}

variable "db_engine_version" {
  description = "Versão do MariaDB no RDS. Quando nulo, usa padrão suportado pela AWS."
  type        = string
  default     = null
}

variable "db_instance_class" {
  description = "Classe da instância RDS."
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "Armazenamento inicial do RDS em GiB."
  type        = number
  default     = 20
}

variable "db_max_allocated_storage" {
  description = "Limite de autoscaling do armazenamento do RDS em GiB."
  type        = number
  default     = 50
}

variable "db_backup_retention_period" {
  description = "Retenção de backup automático do RDS em dias."
  type        = number
  default     = 1
}

variable "db_multi_az" {
  description = "Habilita Multi-AZ no RDS."
  type        = bool
  default     = false
}

variable "db_skip_final_snapshot" {
  description = "Ignora snapshot final ao destruir o RDS. Padrão adequado para dev."
  type        = bool
  default     = true
}

variable "db_deletion_protection" {
  description = "Habilita proteção contra exclusão do RDS."
  type        = bool
  default     = false
}

variable "ec2_instance_type" {
  description = "Tipo da instância EC2 privada."
  type        = string
  default     = "t3.micro"
}

variable "ec2_key_name" {
  description = "Key pair opcional para SSH restrito. Padrão nulo."
  type        = string
  default     = null
}

variable "ec2_root_volume_size" {
  description = "Tamanho do volume raiz da EC2 em GiB."
  type        = number
  default     = 20
}

variable "repository_url" {
  description = "Repositório público clonado pela EC2 no user_data."
  type        = string
  default     = "https://github.com/LuizPazdziora/mercantis-move2cloud"
}

variable "repository_branch" {
  description = "Branch implantada pela EC2."
  type        = string
  default     = "main"
}

variable "allowed_origins" {
  description = "Origens CORS permitidas pelo backend. Com proxy /api, o navegador usa a mesma origem do ALB."
  type        = string
  default     = "*"
}

variable "common_tags" {
  description = "Tags comuns do ambiente dev."
  type        = map(string)
  default = {
    Project   = "Mercantis Move2Cloud"
    ManagedBy = "Terraform"
  }
}
