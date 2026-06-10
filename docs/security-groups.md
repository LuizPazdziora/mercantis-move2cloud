# Mercantis Move2Cloud — Security Groups

Este documento consolida as regras de Security Groups do MVP e da arquitetura final TO-BE. O documento principal permanece autossuficiente em `docs/mercantis-move2cloud-documentacao.md`.

## MVP

| Security Group | Recurso associado | Direção | Protocolo | Porta | Origem/Destino | Justificativa |
|---|---|---|---|---:|---|---|
| `sg-alb` | Application Load Balancer | Entrada | TCP | 443 | CloudFront | Tráfego HTTPS público controlado. |
| `sg-alb` | Application Load Balancer | Entrada | TCP | 80 | CloudFront | Apenas redirect HTTP para HTTPS. |
| `sg-alb` | Application Load Balancer | Saída | TCP | 80/8080 | `sg-ec2-app` | Encaminhamento para containers na EC2 privada. |
| `sg-ec2-app` | EC2 privada | Entrada | TCP | 80/8080 | `sg-alb` | Apenas ALB acessa a aplicação. |
| `sg-ec2-app` | EC2 privada | Entrada | TCP | 22 | Bloqueado | SSH público não deve existir. |
| `sg-ec2-app` | EC2 privada | Saída | TCP | 3306 | `sg-rds` | Backend acessa MariaDB. |
| `sg-ec2-app` | EC2 privada | Saída | TCP | 443 | NAT Gateway / AWS APIs | Atualizações, Docker pull, logs e segredos. |
| `sg-rds` | Amazon RDS for MariaDB | Entrada | TCP | 3306 | `sg-ec2-app` | Somente aplicação acessa banco. |
| `sg-rds` | Amazon RDS for MariaDB | Saída | Stateful | Dinâmica | Resposta stateful | Sem exposição pública. |

## Arquitetura Final TO-BE

| Security Group | Recurso associado | Direção | Protocolo | Porta | Origem/Destino | Justificativa |
|---|---|---|---|---:|---|---|
| `sg-alb` | Application Load Balancer | Entrada | TCP | 443 | CloudFront | Tráfego HTTPS vindo da borda. |
| `sg-alb` | Application Load Balancer | Entrada | TCP | 80 | CloudFront | Apenas redirect HTTPS. |
| `sg-alb` | Application Load Balancer | Saída | TCP | 80/8080 | `sg-ecs-frontend` | Encaminhamento para frontend. |
| `sg-ecs-frontend` | ECS Fargate Service — Frontend | Entrada | TCP | 80/8080 | `sg-alb` | Apenas ALB acessa frontend. |
| `sg-ecs-frontend` | ECS Fargate Service — Frontend | Saída | TCP | 8000/8080 | `sg-ecs-backend` | Frontend chama backend/API. |
| `sg-ecs-backend` | ECS Fargate Service — Backend/API | Entrada | TCP | 8000/8080 | `sg-ecs-frontend` ou `sg-alb` | Chamadas internas controladas. |
| `sg-ecs-backend` | ECS Fargate Service — Backend/API | Saída | TCP | 3306 | `sg-rds` | Backend acessa MariaDB. |
| `sg-ecs-backend` | ECS Fargate Service — Backend/API | Saída | TCP | 443 | AWS APIs, Secrets Manager, ECR, S3, CloudWatch | Integração com serviços AWS. |
| `sg-rds` | Amazon RDS for MariaDB Multi-AZ | Entrada | TCP | 3306 | `sg-ecs-backend` | Somente backend acessa banco. |
| `sg-rds` | Amazon RDS for MariaDB Multi-AZ | Saída | Stateful | Dinâmica | Resposta stateful | Banco privado, sem acesso público. |

## Restrições obrigatórias

- RDS sem IP público.
- Nenhum acesso direto de usuários à EC2 do MVP, aos containers, aos serviços ECS da arquitetura final ou ao RDS.
- Nenhum SSH público.
- Frontend sem acesso direto ao banco.
- Backend como única camada autorizada a acessar MariaDB.
- Porta 80 pública apenas para redirecionamento para HTTPS.
