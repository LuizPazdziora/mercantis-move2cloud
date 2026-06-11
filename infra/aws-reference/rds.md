# Referência de RDS

## Objetivo

Planejar o banco de produção como Amazon RDS for MariaDB em subnet privada.

## Diretrizes

- Engine MariaDB.
- Subnet privada de banco.
- Sem IP público.
- Acesso permitido somente pelo Security Group do backend.
- Backups automáticos configurados conforme RPO definido.
- Credenciais gerenciadas fora do código-fonte.

## Restrições

- Não expor porta 3306 para a internet.
- Não armazenar senha real em `.env`, `docker-compose.yml` ou documentação.
- Não usar dados reais no MVP local.
