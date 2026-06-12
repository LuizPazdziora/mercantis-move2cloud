# Módulo RDS

Este módulo cria o Amazon RDS for MariaDB privado do ambiente dev.

## Recursos

- DB Subnet Group em subnets privadas de banco.
- Instância Amazon RDS for MariaDB.
- Criptografia em repouso.
- Backup automático configurável.
- `publicly_accessible = false`.
- `db_password` como variável sensível.

## Observações

O RDS aceita tráfego `3306` somente do Security Group da aplicação. A senha deve ser informada em `dev.tfvars` local ou mecanismo seguro equivalente, nunca no GitHub.
