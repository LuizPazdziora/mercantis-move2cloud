# Mercantis Move2Cloud — Roadmap

## Fase 1 — MVP acadêmico

- EC2 privada com Docker Compose.
- `frontend-container` e `backend-api-container`.
- Amazon RDS for MariaDB privado.
- Application Load Balancer.
- Amazon CloudFront, AWS WAF, AWS Shield Standard e ACM.
- Amazon CloudWatch para logs e métricas essenciais.
- Documentação, validação técnica e evidências.

## Fase 2 — Produção inicial

- Migração de containers para ECS/Fargate.
- Amazon ECR para versionamento de imagens Docker.
- Amazon RDS for MariaDB Multi-AZ.
- AWS Secrets Manager como padrão de credenciais.
- CloudWatch com métricas, alarmes e dashboards.
- Processo de deploy versionado e rollback.

## Fase 3 — Segurança e observabilidade avançadas

- Amazon GuardDuty.
- AWS Security Hub.
- AWS Config.
- Amazon OpenSearch Service.
- AWS X-Ray.
- VPC Flow Logs amadurecidos.
- Dashboards executivos e técnicos.

## Fase 4 — Evolução da aplicação

- CI/CD.
- Testes automatizados.
- Cache com Amazon ElastiCache.
- Assets desacoplados em Amazon S3 com distribuição via CloudFront.
- Melhorias de catálogo, carrinho, checkout e operação comercial.
