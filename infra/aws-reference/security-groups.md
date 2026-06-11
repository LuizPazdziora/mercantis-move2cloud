# Referência de Security Groups

## Camadas

- Entrada pública controlada.
- Aplicação.
- Banco de dados.

## Regras mínimas

| Security Group | Direção | Porta | Origem/Destino | Finalidade |
|---|---|---:|---|---|
| `sg-public-entry` | Entrada | 443 | Internet controlada | Receber HTTPS quando liberado. |
| `sg-app` | Entrada | 80/8000 | `sg-public-entry` | Receber tráfego da camada de entrada. |
| `sg-app` | Saída | 3306 | `sg-db` | Permitir acesso do backend ao MariaDB. |
| `sg-db` | Entrada | 3306 | `sg-app` | Permitir acesso somente pela aplicação. |

## Restrições

- Porta 22 não deve ser aberta para a internet.
- RDS não deve aceitar tráfego de `0.0.0.0/0`.
- Frontend não deve acessar o banco diretamente.
