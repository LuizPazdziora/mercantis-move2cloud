# Mercantis Move2Cloud - Security Groups

Este documento consolida a referência inicial de Security Groups para a evolução AWS do projeto.

## Camadas

- Entrada pública controlada.
- Aplicação.
- Banco de dados.

## Regras de referência

| Security Group | Recurso associado | Direção | Porta | Origem/Destino | Justificativa |
|---|---|---|---:|---|---|
| `sg-public-entry` | Camada de entrada HTTPS | Entrada | 443 | Internet controlada | Receber tráfego público somente quando liberado. |
| `sg-app` | Camada de aplicação | Entrada | 80/8000 | `sg-public-entry` | Permitir tráfego vindo da entrada controlada. |
| `sg-app` | Camada de aplicação | Saída | 3306 | `sg-db` | Permitir acesso do backend ao MariaDB. |
| `sg-db` | Amazon RDS for MariaDB | Entrada | 3306 | `sg-app` | Restringir o banco à aplicação. |

## Restrições obrigatórias

- RDS sem IP público.
- Usuários externos sem acesso direto ao banco.
- Frontend sem acesso direto ao banco.
- Backend como única camada autorizada a acessar MariaDB.
- Porta 22 fechada para a internet.
- Nenhuma regra de banco aberta para `0.0.0.0/0`.
