# Backup e Rollback

Este documento descreve a estratégia de backup e rollback para a arquitetura AWS de referência do Mercantis Move2Cloud.

## Backups do RDS

O Amazon RDS for MariaDB deve ter backups automáticos habilitados. A janela de retenção deve ser definida conforme necessidade operacional, custo e criticidade do ambiente.

Antes de mudanças críticas, deve ser criado snapshot manual do RDS. Mudanças críticas incluem alteração de schema, atualização de versão, migração de dados ou troca de configuração sensível.

## Rollback da Aplicação

O rollback da aplicação deve ocorrer por retorno a uma imagem Docker anterior e conhecida. Para isso, as imagens de `frontend-container` e `backend-api-container` devem ter tags rastreáveis.

Procedimento conceitual:

1. Identificar a última imagem estável.
2. Parar ou substituir o container com falha.
3. Executar a imagem anterior.
4. Validar o fluxo pelo ALB.
5. Validar `/health`, `/db-health`, `/products` e `/orders`.
6. Registrar evidência do rollback.

## Rollback do Banco

Rollback do banco deve ser tratado separadamente do rollback da aplicação. Restaurar snapshot de RDS pode causar perda de dados gravados após o ponto de restauração.

Antes de restaurar banco, avaliar:

- dados criados após o snapshot;
- compatibilidade entre schema e versão da aplicação;
- necessidade de congelar escrita temporariamente;
- impacto nos usuários;
- plano de comunicação e evidências.

## S3 Como Apoio Opcional

Amazon S3 pode ser usado futuramente como destino auxiliar para artefatos de implantação, exportações ou backups complementares. Ele não é dependência obrigatória do MVP.

## Separação Entre Aplicação e Banco

Rollback de aplicação e rollback de banco não são equivalentes. Uma imagem Docker pode ser revertida sem restaurar o banco. O rollback de banco deve ser usado apenas quando a falha envolver dados, schema ou corrupção.

## Plano de Recuperação

1. Identificar se a falha está na borda, ALB, EC2, containers, RDS ou rede.
2. Preservar logs e métricas no CloudWatch.
3. Isolar impacto, se necessário.
4. Executar rollback de aplicação quando a falha estiver no deploy.
5. Avaliar snapshot ou point-in-time recovery quando a falha estiver no banco.
6. Validar ALB, containers e `/db-health`.
7. Registrar causa raiz e evidências.

## Cuidados

- Não apagar snapshots sem confirmação operacional.
- Não restaurar banco sem avaliar perda de dados.
- Não usar dados fictícios em produção.
- Manter registro de versões de imagem e alterações de schema.
- Testar recuperação em ambiente controlado antes de depender do procedimento.
