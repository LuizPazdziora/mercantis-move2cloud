# Arquitetura AWS do MVP

Este documento descreve a arquitetura AWS de desenvolvimento do Mercantis Move2Cloud. O ambiente atual foi provisionado com Terraform e mantém a estratégia de replatform com refactor parcial: a aplicação continua containerizada, o banco local em container é substituído por Amazon RDS for MariaDB privado e o acesso público ocorre pelo Application Load Balancer.

## Visão Geral

Fluxo atual da aplicação na AWS:

```text
Usuários
-> Application Load Balancer público HTTP/80
-> EC2 privada executando Docker Compose
-> frontend-container com Nginx
-> backend-api-container FastAPI via proxy /api
-> Amazon RDS for MariaDB em subnets privadas
```

O professor acessa o frontend pelo DNS público do ALB. O navegador não chama `localhost`; o frontend usa caminhos relativos, como `/api/health`, `/api/db-health`, `/api/products`, `/api/orders` e `/docs`.

## Objetivos

- Manter a estratégia de replatform com refactor parcial.
- Publicar o frontend por ALB público em HTTP/80.
- Executar frontend e backend em containers Docker dentro de uma EC2 privada.
- Usar Amazon RDS for MariaDB como banco gerenciado privado.
- Evitar exposição direta da EC2 e do RDS à internet.
- Usar AWS Systems Manager Session Manager para acesso administrativo à EC2.
- Preservar suporte ao ambiente local com Docker Compose.
- Manter CloudFront, WAF, ACM, Route 53, Auto Scaling e RDS Multi-AZ como evolução futura.

## Relação Entre Ambiente Local e AWS

| Camada | Execução local | Ambiente AWS de desenvolvimento |
| --- | --- | --- |
| Entrada | Navegador em `localhost:8080` | DNS público do Application Load Balancer em HTTP/80 |
| Frontend | Container Nginx em `localhost:8080` | `frontend-container` em EC2 privada, publicado pelo ALB |
| Backend | FastAPI em `localhost:8000` | `backend-api-container` acessado pelo Nginx via `/api` |
| Banco | MariaDB em container Docker, host local `3307` | Amazon RDS for MariaDB privado na porta `3306` |
| Rede | Rede interna do Docker Compose | VPC `10.0.0.0/16` com subnets públicas, privadas de aplicação e privadas de banco |
| Saída da aplicação | Host local | NAT Gateway para saída controlada da EC2 privada |
| Segredos | `.env` local não versionado | `dev.tfvars` local e `.env` gerado internamente na EC2 via `user_data` |
| Acesso administrativo | Terminal local | AWS Systems Manager Session Manager |

## Componentes Atuais

### Application Load Balancer

O ALB é o ponto público do ambiente de desenvolvimento. Ele recebe HTTP/80 nas subnets públicas e encaminha o tráfego para a EC2 privada na porta 80.

O Target Group valida a aplicação pelo caminho `/`, servido pelo Nginx do frontend.

### EC2 Privada com Docker Compose

A EC2 fica em subnet privada de aplicação, não recebe IP público e executa o `docker-compose.aws.yml` com apenas dois serviços:

- `frontend`: Nginx servindo a interface na porta 80.
- `backend`: API FastAPI acessível somente na rede Docker interna.

O container `database` não é usado na AWS.

### Nginx do Frontend

O Nginx serve os arquivos estáticos do frontend em `/` e faz proxy para o backend nos caminhos:

- `/api/*`
- `/health`
- `/db-health`
- `/docs`
- `/openapi.json`

Com isso, o navegador usa o mesmo domínio do ALB para frontend, API e Swagger.

### Backend FastAPI

O backend executa como container privado na EC2 e se conecta ao RDS pelo endpoint privado informado no `.env` gerado pelo `user_data`.

Endpoints validados no ambiente AWS:

- `/api/health`
- `/api/db-health`
- `/api/products`
- `/api/orders`

### Amazon RDS for MariaDB

O RDS fica em subnets privadas de banco, sem IP público e com acesso restrito ao Security Group da aplicação na porta `3306`.

### VPC, Subnets e NAT Gateway

A VPC separa:

- Subnets públicas para ALB, Internet Gateway e NAT Gateway.
- Subnets privadas de aplicação para EC2.
- Subnets privadas de banco para RDS.

O NAT Gateway permite que a EC2 privada baixe pacotes, clone o repositório e baixe imagens Docker sem receber conexões iniciadas pela internet.

### Security Groups

Os Security Groups segmentam a comunicação:

- `SG-ALB`: recebe HTTP/80 da internet.
- `SG-EC2-APP`: recebe porta 80 somente do `SG-ALB`.
- `SG-RDS`: recebe porta 3306 somente do `SG-EC2-APP`.

SSH não é aberto por padrão. O acesso administrativo deve ocorrer por Session Manager.

### IAM Role

A EC2 usa IAM Role e Instance Profile. Access keys fixas não devem ser gravadas na instância, no repositório ou em imagens Docker.

## Componentes de Evolução Futura

Os itens abaixo não fazem parte da implantação AWS atual e devem ser tratados como evolução:

- CloudFront para CDN e borda global.
- AWS WAF para regras de proteção web.
- AWS Shield Standard como proteção DDoS gerenciada.
- AWS Certificate Manager e HTTPS.
- Route 53 e domínio próprio.
- AWS Secrets Manager ou SSM Parameter Store para gestão de segredos.
- CloudWatch com dashboards, métricas e alarmes detalhados.
- Auto Scaling Group para múltiplas EC2.
- RDS Multi-AZ para maior disponibilidade.
- S3 para artefatos, evidências, exportações ou arquivos estáticos futuros.

## Limitações e Cuidados Operacionais

- O ALB atual usa HTTP/80, não HTTPS.
- A EC2 privada roda uma implantação simples com Docker Compose.
- A segunda zona de aplicação fica preparada para expansão, mas não implica alta disponibilidade completa.
- Um único NAT Gateway reduz complexidade e custo, mas não oferece resiliência por zona.
- A infraestrutura AWS gera custos enquanto estiver ativa.
- O arquivo `dev.tfvars` deve existir apenas localmente e nunca ser versionado.
- Senhas reais, access keys, secret keys e tokens não devem aparecer em commits, documentação ou arquivos de exemplo.

Para encerrar o ambiente após a validação, execute manualmente, a partir de `infra/terraform/envs/dev`:

```bash
terraform destroy -var-file="dev.tfvars"
```
