# Documentação Técnica

## Objetivo

O Mercantis Move2Cloud é um MVP de aplicação web com foco em arquitetura AWS, segurança, documentação técnica e demonstração funcional mínima. A base atual mantém separação entre frontend, backend e banco de dados e possui execução local com Docker Compose e ambiente AWS de desenvolvimento provisionado com Terraform.

## Execução local

O ambiente local usa Docker Compose com três serviços:

- `frontend`: interface web simples servida por Nginx.
- `backend`: API FastAPI em Python.
- `database`: MariaDB para desenvolvimento local.

## Arquitetura AWS de desenvolvimento

A implantação AWS atual segue a estratégia de replatform com refactor parcial. O ponto de entrada é um Application Load Balancer público em HTTP/80, a aplicação roda em uma EC2 privada com Docker Compose e o banco de dados é Amazon RDS for MariaDB em subnets privadas.

Na AWS, o frontend é servido por Nginx, o backend FastAPI é acessado pelo proxy `/api` e o banco local em container não é usado.

## Escopo implementado nesta base

- Estrutura de diretórios do backend.
- Estrutura de diretórios do frontend.
- Dockerfile para backend e frontend.
- Docker Compose com frontend, backend e database.
- Docker Compose AWS com frontend e backend, sem container de banco.
- Scripts iniciais de banco.
- Endpoint `/health`.
- Infraestrutura Terraform para VPC, ALB, EC2 privada e RDS privado.
- Documentação técnica inicial.

## Limites

- Não há pagamento real.
- Não há integração logística.
- Não há antifraude.
- Não há estoque real.
- Não há dados reais de clientes.
- Componentes como CloudFront, WAF, ACM, Route 53, Auto Scaling e RDS Multi-AZ permanecem como evolução futura.
