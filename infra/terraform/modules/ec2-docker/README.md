# Módulo EC2 Docker

Este módulo cria a EC2 privada que executa os containers da aplicação.

## Recursos

- Data source para AMI Amazon Linux 2023.
- IAM Role para EC2.
- Instance Profile.
- EC2 em subnet privada de aplicação, sem IP público.
- `user_data` para instalar Docker, clonar o repositório, gerar `.env`, inicializar o schema do RDS e executar `docker-compose.aws.yml`.

## Observações

O container `database` não é usado na AWS. O backend acessa o Amazon RDS for MariaDB privado usando o endpoint criado pelo módulo `rds`.

O `user_data` recebe a senha do banco em tempo de criação da instância. Em produção, a recomendação é usar AWS Secrets Manager ou SSM Parameter Store.
