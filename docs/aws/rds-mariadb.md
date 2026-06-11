# Amazon RDS for MariaDB

Este documento descreve o uso de Amazon RDS for MariaDB na arquitetura AWS de referencia do Mercantis Move2Cloud.

## Uso previsto

O RDS substitui o MariaDB local em container. A aplicacao continua usando MariaDB como banco relacional, mas delega operacoes de infraestrutura para um servico gerenciado da AWS.

## Justificativa

- Mantem compatibilidade com o banco usado localmente.
- Reduz responsabilidade operacional sobre backups, armazenamento e manutencao.
- Permite isolamento em subnet privada.
- Facilita monitoramento com metricas integradas.

## Posicionamento de rede

O RDS deve ficar em subnets privadas, com `Public accessibility` desabilitado. O acesso deve ser permitido apenas a partir do Security Group da EC2, na porta `3306`.

```text
EC2 / SG-EC2 -> 3306 -> RDS MariaDB / SG-RDS
```

Nao deve existir regra permitindo acesso ao RDS a partir de `0.0.0.0/0`.

## Backup e protecao

- Habilitar backup automatico do RDS.
- Definir janela de backup compatibilidade com a operacao.
- Criar snapshot manual antes de mudancas criticas.
- Avaliar criptografia em repouso com KMS.
- Avaliar Multi-AZ como evolucao recomendada para maior resiliencia.

## Cuidados com senha

Senhas nao devem ser gravadas no GitHub, em Dockerfile ou em imagens Docker. No MVP local, `.env` e usado apenas localmente e nao deve ser versionado. Em AWS, a evolucao recomendada e armazenar a senha no AWS Secrets Manager e conceder leitura apenas a role da aplicacao.

## MariaDB local e RDS MariaDB

| Aspecto | Local | AWS |
| --- | --- | --- |
| Execucao | Container `database` | Amazon RDS for MariaDB |
| Porta interna | `database:3306` | Endpoint privado do RDS em `3306` |
| Dados demonstrativos | `seed.sql` | Nao usar dados ficticios em producao |
| Administracao | Docker Compose | Console/API AWS e politicas operacionais |
| Backup | Volume local | Backup automatico e snapshots |

## Migracao de schema

- `database/init.sql` deve ser tratado como referencia inicial de schema.
- `database/seed.sql` deve ser usado apenas para dados demonstrativos.
- Dados ficticios nao devem ser aplicados em producao.
- Mudancas futuras devem evoluir para estrategia controlada de migracao, com versionamento de scripts e plano de rollback.

## Validacao esperada

- Endpoint privado do RDS acessivel pela EC2.
- Porta `3306` bloqueada para a internet.
- Backend responde `/db-health` com conexao valida.
- Backups automaticos habilitados.
- Configuracao documentada sem exposicao de credenciais.
