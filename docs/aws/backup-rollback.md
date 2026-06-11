# Backup e Rollback

Este documento descreve a estrategia de backup e rollback para a arquitetura AWS de referencia do Mercantis Move2Cloud.

## Backups do RDS

O Amazon RDS for MariaDB deve ter backups automaticos habilitados. A janela de retencao deve ser definida conforme criticidade do ambiente e custo aceitavel.

Antes de mudancas criticas, deve ser criado snapshot manual do RDS. Mudancas criticas incluem alteracao de schema, atualizacao de versao, migracao de dados ou troca de configuracoes sensiveis.

## Rollback da aplicacao

O rollback da aplicacao deve ser feito retornando para uma imagem Docker anterior e conhecida. Para isso, cada imagem deve ser versionada de forma rastreavel, por exemplo com tag de versao ou hash de commit.

Procedimento conceitual:

1. Identificar a ultima imagem estavel.
2. Parar o container com falha.
3. Executar a imagem anterior.
4. Validar `/health`, `/db-health`, `/products` e `/orders`.
5. Registrar evidencia do rollback.

## Rollback do banco

O rollback de banco deve ser tratado com maior cautela porque pode envolver perda de dados. As opcoes incluem restaurar snapshot para uma nova instancia RDS ou recuperar um ponto no tempo, conforme configuracao disponivel.

Antes de restaurar, deve-se avaliar:

- dados gravados apos o ponto de restauracao;
- impacto nos usuarios;
- compatibilidade entre versao da aplicacao e schema;
- necessidade de congelar escrita temporariamente.

## Separacao entre aplicacao e banco

Rollback de aplicacao e rollback de banco nao sao equivalentes. E possivel retornar a aplicacao para uma imagem anterior sem restaurar o banco. Restaurar banco deve ser ultima medida quando a falha envolve dados, schema ou corrupcao.

## Plano de recuperacao

1. Identificar tipo de falha: aplicacao, infraestrutura ou banco.
2. Preservar logs e evidencias.
3. Isolar impacto, se necessario.
4. Executar rollback de aplicacao quando a falha estiver no deploy.
5. Avaliar snapshot ou point-in-time recovery quando a falha estiver no banco.
6. Validar endpoints criticos.
7. Revisar causa raiz antes de nova publicacao.

## Cuidados

- Nunca apagar snapshots sem confirmacao operacional.
- Nao executar rollback de banco sem avaliar perda de dados.
- Manter registro de versoes de imagem e alteracoes de schema.
- Testar recuperacao em ambiente controlado antes de depender do procedimento em producao.
