# Diagrama do MVP

Este documento descreve a visão inicial do MVP Mercantis Move2Cloud. O desenho local usa três serviços em Docker Compose:

- `frontend`: interface web simples e containerizada.
- `backend`: API em Python com FastAPI.
- `database`: MariaDB local para desenvolvimento.

Na referência AWS, o MVP deve ser mantido em ambiente controlado, com aplicação em camada privada e banco Amazon RDS for MariaDB em subnet privada. O acesso público só deve ocorrer após validação e liberação explícita.

## Fluxo local

```text
Usuário local
-> frontend
-> backend FastAPI
-> MariaDB
```

## Fluxo AWS planejado para validação controlada

```text
Usuário
-> camada pública controlada
-> balanceamento HTTP/HTTPS
-> instância privada com containers
-> Amazon RDS for MariaDB em subnet privada
```

Imagem de referência preservada no repositório:

![Diagrama MVP](../images/diagrama-mvp.png)
