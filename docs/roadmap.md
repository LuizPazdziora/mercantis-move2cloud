# Mercantis Move2Cloud - Roadmap

## Fase 1 - Estrutura inicial local ✅

- Estrutura do backend FastAPI, frontend containerizado e MariaDB local com Docker Compose.
- Endpoints de saúde (`/health` e `/db-health`).
- Documentação técnica inicial.

## Fase 2 - MVP funcional mínimo ✅

- CRUD de produtos fictícios e fluxo simplificado de pedidos persistidos no MariaDB.
- Validações com Pydantic e tratamento de erros (404, 400, 409, 422).
- Testes automatizados da API (pytest + SQLite em memória) executados no GitHub Actions.

## Fase 3 - Ambiente AWS de desenvolvimento ✅

- VPC com subnets públicas, privadas de aplicação e privadas de banco.
- Application Load Balancer público, EC2 privada com Docker Compose e Amazon RDS for MariaDB privado.
- Security Groups por camada, NAT Gateway e acesso administrativo por Session Manager.
- Infraestrutura provisionada com Terraform em módulos.

## Fase 4 - Evolução para produção (planejada)

- HTTPS com ACM, CloudFront, AWS WAF e Route 53.
- Segredos no AWS Secrets Manager.
- Logs, métricas e alarmes no CloudWatch.
- Alta disponibilidade (Auto Scaling, RDS Multi-AZ) e migração para ECS Fargate (arquitetura *to-be*).
- Pipeline de CI/CD com build e publicação das imagens.
- State remoto do Terraform em S3 com lock.
