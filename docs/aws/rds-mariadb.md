# Amazon RDS for MariaDB

Este documento descreve o uso de Amazon RDS for MariaDB no ambiente AWS de desenvolvimento do Mercantis Move2Cloud.

## Uso Atual

O RDS substitui o MariaDB local em container no ambiente AWS. A aplicação continua usando MariaDB como banco relacional, mas o banco passa a ser gerenciado pela AWS e posicionado em subnets privadas de banco.

## Justificativa

- Mantém compatibilidade com o banco usado localmente.
- Reduz responsabilidade operacional sobre backup, armazenamento e manutenção.
- Permite isolamento em subnets privadas.
- Evita exposição direta do banco à internet.
- Facilita monitoramento com métricas integradas.

## Posicionamento de Rede

O RDS deve ficar nas subnets privadas de banco:

- `10.0.21.0/24`
- `10.0.22.0/24`

Essas subnets compõem o DB Subnet Group. Mesmo que o MVP comece simples, usar subnets em mais de uma zona prepara a evolução para Multi-AZ.

## Acesso Público

`Public accessibility` deve permanecer desativado. O RDS não deve ter IP público e não deve receber conexão direta da internet.

Regra esperada:

```text
SG-EC2-APP -> TCP 3306 -> SG-RDS
```

Não deve existir regra permitindo `3306` a partir de `0.0.0.0/0`.

## Backups e Proteção

- Habilitar backup automático do RDS.
- Definir janela de retenção conforme necessidade operacional.
- Criar snapshot manual antes de mudanças críticas.
- Avaliar criptografia em repouso com KMS.
- Avaliar Multi-AZ como evolução futura.

## Cuidados Com Senhas

Senhas não devem ser gravadas no GitHub, em Dockerfile, em imagens Docker ou em comandos de execução. No ambiente local, `.env` é usado apenas para desenvolvimento e não deve ser versionado. Em AWS, a evolução recomendada é Secrets Manager com leitura restrita à IAM Role da aplicação.

## MariaDB Local e RDS MariaDB

| Aspecto | Local | AWS |
| --- | --- | --- |
| Execução | Container `database` | Amazon RDS for MariaDB |
| Host | `database` na rede Docker | Endpoint privado do RDS |
| Porta | `3306` interna e `3307` no host local | `3306` privada |
| Dados demonstrativos | `seed.sql` | `seed.sql` aplicado no ambiente dev; não usar dados fictícios em produção |
| Backup | Volume Docker local | Backup automático e snapshots |
| Segurança | Rede Docker local | Subnet privada e Security Group |

## Migração de Schema

- `database/init.sql` é referência inicial de schema.
- `database/seed.sql` é apenas para dados demonstrativos.
- Dados fictícios não devem ser aplicados em produção.
- Mudanças futuras devem evoluir para estratégia controlada de migração, com scripts versionados e plano de rollback.

## Validação Esperada

- RDS sem acesso público.
- RDS em subnets privadas de banco.
- Porta `3306` acessível apenas a partir do Security Group da aplicação.
- Backend responde `/db-health` com conexão válida.
- Backups automáticos habilitados ou planejados.
- Credenciais fora do repositório.
