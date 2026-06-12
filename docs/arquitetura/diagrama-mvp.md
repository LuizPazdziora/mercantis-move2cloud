# Diagrama do MVP

Este documento descreve a visão inicial do MVP Mercantis Move2Cloud. O desenho local usa três serviços em Docker Compose:

- `frontend`: interface web simples e containerizada.
- `backend`: API em Python com FastAPI.
- `database`: MariaDB local para desenvolvimento.

Na AWS, o MVP é mantido em ambiente controlado, com Application Load Balancer público, aplicação em EC2 privada e banco Amazon RDS for MariaDB em subnet privada. O acesso público atual ocorre pelo ALB em HTTP/80 para validação do MVP.

## Fluxo local

```text
Usuário local
-> frontend
-> backend FastAPI
-> MariaDB
```

## Fluxo AWS de validação controlada

```text
Usuário
-> Application Load Balancer público HTTP/80
-> EC2 privada com containers Docker
-> Amazon RDS for MariaDB em subnet privada
```

Imagem de referência preservada no repositório:

![Diagrama MVP](../images/diagrama-mvp.png)
