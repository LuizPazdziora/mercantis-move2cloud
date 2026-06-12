# Backend remoto planejado para fase futura.
#
# O bucket de state ainda precisa ser criado ou definido.
# O arquivo de state nao deve ser versionado no GitHub.
# Ajustar os placeholders antes de executar `terraform init` com backend remoto.
#
# terraform {
#   backend "s3" {
#     bucket = "NOME_DO_BUCKET_TERRAFORM_STATE"
#     key    = "mercantis/dev/terraform.tfstate"
#     region = "sa-east-1"
#   }
# }
