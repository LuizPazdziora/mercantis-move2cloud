# Mercantis Move2Cloud - Checklist de Segurança

Use este checklist antes de qualquer validação com exposição externa controlada.

| Item | Status | Observação |
|---|---|---|
| MFA ativado para usuários AWS administrativos | Pendente | Aplicar antes de operação em conta AWS. |
| Conta root sem access keys | Pendente | Conta root não deve ser usada em operação diária. |
| HTTPS obrigatório para tráfego público | Pendente | HTTP deve existir apenas para redirecionamento, se usado. |
| RDS sem acesso público | Pendente | `Publicly accessible` deve permanecer desativado. |
| Security Groups revisados | Pendente | Origem por camada, não por abertura ampla. |
| Porta 22 fechada para internet | Pendente | Preferir acesso administrativo controlado. |
| Credenciais fora do repositório | Pendente | Usar serviço seguro em AWS e `.env` apenas localmente. |
| Logs básicos habilitados | Pendente | Registrar aplicação e infraestrutura conforme a etapa. |
| Auditoria habilitada | Pendente | Registrar alterações relevantes em recursos AWS. |
| S3 Block Public Access ativado | Pendente | Aplicar em buckets de evidências, logs e artefatos privados. |
| Backup automático do RDS planejado | Pendente | Definir retenção conforme RPO. |
| Plano de rollback documentado | Pendente | Definir retorno para versão anterior. |
| Plano de desligamento definido | Pendente | Evitar custo e exposição após validação. |
