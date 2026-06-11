# Checklist AWS

Este checklist deve ser usado antes de qualquer publicação controlada do Mercantis Move2Cloud na AWS.

## Rede

[ ] VPC dedicada foi definida.
[ ] VPC usa CIDR `10.0.0.0/16`.
[ ] Região `sa-east-1` foi considerada.
[ ] Subnets públicas e privadas foram separadas.
[ ] Subnets públicas `10.0.1.0/24` e `10.0.2.0/24` foram planejadas.
[ ] Subnets privadas de aplicação `10.0.11.0/24` e `10.0.12.0/24` foram planejadas.
[ ] Subnets privadas de banco `10.0.21.0/24` e `10.0.22.0/24` foram planejadas.
[ ] Internet Gateway atende apenas a camada pública.
[ ] NAT Gateway permite saída controlada da subnet privada de aplicação.
[ ] NAT Gateway por AZ foi avaliado para alta disponibilidade futura.

## ALB e Borda

[ ] ALB está nas subnets públicas.
[ ] CloudFront/WAF/ACM foram planejados para publicação pública.
[ ] AWS Shield Standard foi considerado na camada de borda.
[ ] HTTPS está planejado antes da exposição pública.
[ ] Listener HTTPS 443 foi planejado no ALB ou na camada de borda.
[ ] Health check do ALB foi definido.

## EC2

[ ] EC2 da aplicação está em subnet privada.
[ ] EC2 não recebe tráfego direto da internet.
[ ] EC2 não possui IP público.
[ ] EC2 executa apenas containers necessários.
[ ] `frontend-container` foi planejado.
[ ] `backend-api-container` foi planejado.
[ ] Container `database` não está em uso na arquitetura AWS final.
[ ] SSH está bloqueado ou restrito.
[ ] SSM Session Manager foi avaliado para acesso administrativo.
[ ] IAM Role está associada à EC2.

## RDS

[ ] RDS está em subnet privada de banco.
[ ] RDS está com public accessibility desativado.
[ ] RDS usa DB Subnet Group com mais de uma AZ.
[ ] Porta `3306` não está aberta para `0.0.0.0/0`.
[ ] SG do RDS aceita tráfego somente do SG da aplicação.
[ ] Backups automáticos do RDS estão planejados ou habilitados.
[ ] Criptografia em repouso foi avaliada.
[ ] Multi-AZ foi avaliado como evolução futura.
[ ] `seed.sql` não será usado com dados fictícios em produção.

## Security Groups

[ ] `SG-ALB` recebe `443` da camada de borda.
[ ] `SG-EC2-APP` aceita tráfego somente do `SG-ALB`.
[ ] `SG-RDS` aceita tráfego somente do `SG-EC2-APP`.
[ ] Porta `3306` está restrita ao fluxo aplicação -> RDS.
[ ] Regras amplas foram removidas.
[ ] SSH não está aberto para `0.0.0.0/0`.

## Segredos e IAM

[ ] `.env` não está versionado.
[ ] Nenhuma credencial real está no GitHub.
[ ] Não existem access keys fixas na EC2.
[ ] Senhas não estão em Dockerfiles.
[ ] Senhas não estão em imagens Docker.
[ ] Secrets Manager está planejado para segredos.
[ ] Permissões IAM seguem menor privilégio.

## Aplicação

[ ] Backend conecta ao RDS pelo endpoint privado.
[ ] `DB_PORT` usa `3306` para conexão com RDS.
[ ] CORS foi restringido para o domínio correto.
[ ] Endpoints `/health` e `/db-health` respondem corretamente.
[ ] Swagger não expõe informações sensíveis em ambiente publicado.

## Observabilidade

[ ] CloudWatch está planejado para logs e métricas.
[ ] Logs do backend foram planejados.
[ ] Logs do frontend/Nginx foram planejados.
[ ] Logs do ALB foram planejados.
[ ] Logs do WAF foram planejados.
[ ] Métricas de EC2 foram avaliadas.
[ ] Métricas de RDS foram avaliadas.
[ ] Alarmes de CPU, storage, health check e erros 5xx foram planejados.

## Backup e Rollback

[ ] Backups automáticos do RDS estão planejados ou habilitados.
[ ] Snapshot manual antes de mudanças críticas foi planejado.
[ ] Rollback por imagem Docker anterior foi documentado.
[ ] Rollback de banco por snapshot foi documentado.
[ ] Risco de perda de dados foi avaliado antes de restauração.
[ ] S3 foi avaliado como apoio opcional para artefatos ou backups exportados.

## Custos

[ ] Tipo de instância EC2 foi justificado.
[ ] Classe do RDS foi justificada.
[ ] Custo do NAT Gateway foi avaliado.
[ ] Custo de CloudFront, WAF e logs foi avaliado.
[ ] Recursos temporários têm plano de desativação.

## Pronto Para Publicação

[ ] Checklist de segurança foi revisado.
[ ] Evidências foram registradas.
[ ] HTTPS foi validado.
[ ] CORS foi validado.
[ ] Logs e métricas foram validados.
[ ] Backup e rollback foram validados.
[ ] Liberação controlada foi aprovada.
