# Observabilidade

Este documento descreve a observabilidade recomendada para a arquitetura AWS de referencia do Mercantis Move2Cloud.

## Papel do CloudWatch

CloudWatch deve centralizar metricas, logs e alarmes da aplicacao e dos recursos AWS. A coleta deve permitir diagnosticar indisponibilidade, degradacao de desempenho, falhas de banco e consumo anormal de recursos.

## Logs da aplicacao

Os containers `frontend` e `backend` devem registrar logs em saida padrao para facilitar coleta por agente ou integracao futura. Logs do backend devem permitir identificar:

- chamadas aos endpoints principais;
- falhas de validacao;
- erros de conexao com banco;
- status do endpoint `/health`;
- status do endpoint `/db-health`.

## Logs da EC2

A EC2 deve ter logs de sistema operacional e Docker monitorados conforme maturidade operacional. Em evolucao, o CloudWatch Agent pode coletar logs de sistema, uso de disco e memoria.

## Metricas basicas

| Recurso | Metrica recomendada |
| --- | --- |
| EC2 | CPU |
| EC2 | memoria, se agente configurado |
| EC2 | uso de disco |
| RDS | conexoes ativas |
| RDS | CPU |
| RDS | armazenamento livre |
| Aplicacao | erros HTTP |
| Aplicacao | disponibilidade de `/health` |
| Aplicacao | disponibilidade de `/db-health` |

## Alarmes recomendados

- CPU alta na EC2 por periodo sustentado.
- Armazenamento baixo no RDS.
- Falha recorrente de health check.
- Indisponibilidade da aplicacao.
- Crescimento inesperado de erros HTTP.
- Numero anormal de conexoes no RDS.

## Evidencias esperadas

- Logs centralizados ou plano documentado de coleta.
- Alarmes definidos antes de publicacao real.
- Painel basico com EC2, RDS e disponibilidade.
- Procedimento de investigacao para falhas de banco e aplicacao.
