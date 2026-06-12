variable "project_name" {
  description = "Nome técnico do projeto."
  type        = string
}

variable "environment" {
  description = "Ambiente lógico."
  type        = string
}

variable "alarm_email" {
  description = "E-mail futuro para alarmes, se aprovado."
  type        = string
  default     = ""
}

variable "common_tags" {
  description = "Tags comuns para recursos futuros."
  type        = map(string)
}
