# Observabilidade

Este documento descreve a observabilidade recomendada para a arquitetura AWS de referência do Mercantis Move2Cloud.

## Papel do CloudWatch

Amazon CloudWatch é o serviço recomendado para centralizar logs, métricas e alarmes da aplicação e dos componentes AWS. A observabilidade deve permitir diagnosticar falhas no fluxo `CloudFront/WAF -> ALB -> EC2 privada -> RDS`.

## Logs Recomendados

- Logs do backend FastAPI.
- Logs do Nginx/frontend.
- Logs da EC2 e do Docker.
- Logs do RDS MariaDB.
- Logs do Application Load Balancer.
- Logs do AWS WAF.
- Eventos relevantes de saúde dos containers.

## Métricas Recomendadas

| Componente | Métrica |
| --- | --- |
| EC2 | CPU |
| EC2 | Memória, se CloudWatch Agent estiver configurado |
| EC2 | Uso de disco |
| Docker | Estado dos containers |
| ALB | Erros 4xx e 5xx |
| ALB | Target health |
| ALB | Latência |
| RDS | CPU |
| RDS | Conexões |
| RDS | Storage livre |
| RDS | Latência de leitura e escrita |
| WAF | Requisições bloqueadas |
| Aplicação | Falhas em `/health` e `/db-health` |

## Alarmes Recomendados

- CPU alta na EC2 por período sustentado.
- Disco baixo na EC2.
- Targets unhealthy no ALB.
- Erros 5xx no ALB.
- Falha do endpoint `/health`.
- Falha do endpoint `/db-health`.
- CPU alta no RDS.
- Storage baixo no RDS.
- Crescimento anormal de conexões no RDS.
- Bloqueios recorrentes no WAF.

## Evidências Esperadas

- Logs disponíveis para backend e frontend.
- Estado dos containers registrado.
- Métricas básicas de EC2 e RDS.
- Health checks do ALB documentados.
- Alarmes planejados antes de publicação pública.
- Procedimento de investigação para falhas de aplicação, rede e banco.
