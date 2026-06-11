# Checklist AWS

Este checklist deve ser usado antes de qualquer publicacao controlada do Mercantis Move2Cloud na AWS.

## Rede

[ ] VPC dedicada foi definida.
[ ] CIDR da VPC nao conflita com redes conhecidas.
[ ] Subnets publicas e privadas foram separadas.
[ ] Subnets do RDS estao em pelo menos duas zonas de disponibilidade.
[ ] Internet Gateway esta associado apenas ao fluxo publico esperado.
[ ] Route table publica aponta para o Internet Gateway.
[ ] Route table privada nao expoe RDS diretamente a internet.

## EC2

[ ] EC2 esta com sistema operacional atualizado.
[ ] EC2 executa apenas containers necessarios.
[ ] Container `database` nao esta em uso na arquitetura AWS final.
[ ] Portas de desenvolvimento `8080` e `8000` foram revisadas antes de publicacao.
[ ] SSH da EC2 esta restrito.
[ ] Acesso administrativo sem SSH publico foi avaliado.

## RDS

[ ] RDS esta em subnet privada.
[ ] RDS nao esta publicamente acessivel.
[ ] Porta `3306` nao esta aberta para `0.0.0.0/0`.
[ ] Security Group do RDS aceita conexao apenas da EC2.
[ ] Backup automatico do RDS esta habilitado.
[ ] Criptografia em repouso foi avaliada.
[ ] Multi-AZ foi avaliado como evolucao.
[ ] `seed.sql` nao foi aplicado com dados ficticios em producao.

## Security Groups

[ ] Security Groups estao separados por camada.
[ ] HTTP/HTTPS esta liberado apenas conforme fase de publicacao.
[ ] SSH nao esta aberto para `0.0.0.0/0`.
[ ] Regra MariaDB `3306` permite origem somente do `SG-EC2`.
[ ] Regras sem uso foram removidas.

## IAM

[ ] EC2 usa IAM Role.
[ ] Nao existem access keys fixas na instancia.
[ ] Permissoes IAM seguem menor privilegio.
[ ] Permissao para CloudWatch Logs foi avaliada.
[ ] Permissao read-only para segredos especificos foi avaliada.

## Segredos

[ ] `.env` nao foi versionado.
[ ] Credenciais reais nao estao no GitHub.
[ ] Senha do banco nao esta em Dockerfile.
[ ] Senha do banco nao esta em imagem Docker.
[ ] Secrets Manager foi planejado para evolucao.

## Aplicacao

[ ] Backend conecta ao RDS pelo endpoint privado.
[ ] `DB_PORT` usa `3306` para conexao com RDS.
[ ] CORS foi restringido para o dominio correto.
[ ] Endpoints `/health` e `/db-health` respondem corretamente.
[ ] Swagger nao expoe informacoes sensiveis.

## Observabilidade

[ ] Logs estao sendo enviados para CloudWatch ou documentados.
[ ] Metricas de EC2 foram avaliadas.
[ ] Metricas de RDS foram avaliadas.
[ ] Alarme de CPU alta foi planejado.
[ ] Alarme de storage baixo no RDS foi planejado.
[ ] Falha de health check foi planejada como alarme.

## Backup

[ ] Backups automaticos do RDS estao habilitados.
[ ] Snapshot manual antes de mudancas criticas foi planejado.
[ ] Rollback por imagem Docker anterior foi documentado.
[ ] Rollback de banco por snapshot foi documentado.
[ ] Risco de perda de dados foi avaliado antes de restauracao.

## Custos

[ ] Tipo de instancia EC2 foi justificado.
[ ] Classe do RDS foi justificada.
[ ] Custos de armazenamento e backup foram avaliados.
[ ] Recursos temporarios tem plano de desativacao.
[ ] Monitoramento de custos foi planejado.

## Pronto para publicacao

[ ] HTTPS foi planejado antes de publicacao publica.
[ ] Dominio e certificado foram definidos ou documentados como pendentes.
[ ] Checklist de seguranca foi revisado.
[ ] Validacao funcional foi concluida.
[ ] Evidencias foram registradas.
[ ] Liberacao controlada foi aprovada.
