# Mercantis Move2Cloud — Checklist de Segurança Dia 1

Use este checklist antes de qualquer demonstração ou exposição temporária do MVP.

| Item | Status | Observação |
|---|---|---|
| MFA ativado para usuários AWS | Pendente | Exigir principalmente para contas administrativas. |
| Root account sem access keys | Pendente | Conta root não deve ser usada na operação diária. |
| HTTPS obrigatório | Pendente | HTTP deve redirecionar para HTTPS. |
| AWS WAF ativado | Pendente | Associar à camada de borda prevista. |
| AWS Shield Standard considerado | Pendente | Proteção básica disponível para serviços compatíveis. |
| RDS sem acesso público | Pendente | `Publicly accessible` deve permanecer desativado. |
| Security Groups revisados | Pendente | Validar origem por Security Group, não por `0.0.0.0/0` em camadas privadas. |
| Porta 22 fechada para internet | Pendente | Usar Systems Manager quando houver necessidade operacional. |
| Credenciais no Secrets Manager ou Parameter Store | Pendente | Não versionar senhas em código ou arquivos. |
| CloudTrail ativado | Pendente | Obrigatório na arquitetura final e recomendado desde a validação. |
| CloudWatch Logs ativado | Pendente | Centralizar logs da aplicação e infraestrutura. |
| VPC Flow Logs ativado na arquitetura final | Pendente | Apoia auditoria e diagnóstico de rede. |
| S3 Block Public Access ativado | Pendente | Aplicar em buckets de evidências, logs, backups e artefatos. |
| Backup automático do RDS habilitado | Pendente | Definir retenção compatível com RPO. |
| Plano de rollback documentado | Pendente | Definir retorno para versão anterior da aplicação. |
| Plano de descomissionamento definido | Pendente | Evitar custo e exposição após testes. |
