# Mercantis Move2Cloud

O Mercantis Move2Cloud é um MVP de aplicação web containerizada para validar uma base técnica de migração para AWS. O projeto usa a estratégia de replatform com refactor parcial: a aplicação é organizada em containers e o ambiente AWS de desenvolvimento utiliza Application Load Balancer público, EC2 privada com Docker Compose e Amazon RDS for MariaDB em subnets privadas.

O projeto mantém dois modos de execução: local com Docker Compose e AWS provisionado com Terraform.

## Status Atual do MVP

Ambiente AWS de desenvolvimento:

- Frontend publicado via Application Load Balancer HTTP/80.
- EC2 privada executando `docker-compose.aws.yml` com containers `frontend` e `backend`.
- Frontend servido por Nginx.
- Backend FastAPI acessado via proxy `/api`.
- Amazon RDS for MariaDB privado, sem IP público.
- Swagger acessível pelo ALB em `/docs`.
- Endpoints validados: `/api/health`, `/api/db-health` e `/api/products`.

Execução local:

- Frontend funcional em `http://localhost:8080`.
- Backend FastAPI em `http://localhost:8000`.
- Swagger em `http://localhost:8000/docs`.
- MariaDB em container Docker.
- MariaDB interno em `3306`.
- MariaDB publicado localmente em `127.0.0.1:3307`.
- Fluxo validado: `Frontend -> Backend FastAPI -> MariaDB`.

## Arquitetura Local

```text
Navegador
-> frontend / Nginx / porta 8080
-> backend / FastAPI / porta 8000
-> database / MariaDB / database:3306
```

O frontend não acessa o banco diretamente. A comunicação com o MariaDB é feita somente pelo backend usando o host interno `database` e a porta `3306`.

## Arquitetura AWS de Desenvolvimento

```text
Usuário
-> Application Load Balancer público HTTP/80
-> EC2 privada executando Docker Compose
-> Frontend Nginx
-> Backend FastAPI via /api
-> Amazon RDS for MariaDB privado
```

Na AWS, o banco não roda em container. O `docker-compose.aws.yml` sobe apenas frontend e backend. O acesso administrativo à EC2 deve ser feito por AWS Systems Manager Session Manager.

## Tecnologias

- HTML, CSS e JavaScript puro no frontend.
- Nginx para servir o frontend.
- Python com FastAPI no backend.
- SQLAlchemy e PyMySQL para acesso ao banco.
- Pydantic para validação de entrada e saída.
- MariaDB em container para execução local.
- Amazon RDS for MariaDB privado para execução AWS.
- Docker Compose para orquestração local e para containers da aplicação na EC2.
- Terraform para provisionamento da infraestrutura AWS de desenvolvimento.

## Estrutura de Pastas

```text
backend/
frontend/
database/
docs/
infra/
docker-compose.yml
.env.example
codex-instructions.md
README.md
```

## Configurar Variáveis de Ambiente

Antes de executar o Docker Compose, crie o arquivo `.env` local a partir do exemplo versionado.

Windows PowerShell:

```powershell
copy .env.example .env
```

Alternativa multiplataforma:

```bash
cp .env.example .env
```

O arquivo `.env` é necessário apenas localmente, não deve ser versionado e não deve conter credenciais reais de produção.

## Subir o Ambiente

```powershell
docker compose up -d --build
```

Verificar containers:

```powershell
docker compose ps
```

Resultado esperado:

- `mercantis-frontend` em execução.
- `mercantis-backend` em execução.
- `mercantis-database` em execução e `healthy`.

## URLs Locais

- Frontend: `http://localhost:8080`
- Backend Swagger: `http://localhost:8000/docs`
- API Health: `http://localhost:8000/health`
- DB Health: `http://localhost:8000/db-health`
- Produtos: `http://localhost:8000/products`
- Pedidos: `http://localhost:8000/orders`

## Validação Rápida

```powershell
Invoke-RestMethod http://localhost:8000/health
Invoke-RestMethod http://localhost:8000/db-health
Invoke-RestMethod http://localhost:8000/products
Invoke-RestMethod http://localhost:8000/orders
```

Valide também no navegador:

- `http://localhost:8080`
- `http://localhost:8000/docs`

## Porta 3307 do MariaDB

O MariaDB usa duas portas com finalidades diferentes:

- `3306`: porta interna do container, usada pelo backend como `database:3306`.
- `3307`: porta publicada no host local para ferramentas como DBeaver, MySQL Workbench ou terminal.

Essa separação evita conflito com instalações locais de MySQL, MariaDB, XAMPP ou WAMP que costumam ocupar a porta `3306`.

## Volume MariaDB

Os scripts `database/init.sql` e `database/seed.sql` são executados automaticamente apenas quando o volume do banco é criado pela primeira vez. Se o volume já existir, alterações nesses scripts podem não ser reaplicadas.

Use `docker compose down -v` somente quando for aceitável apagar todos os dados locais e recriar o banco do zero. Em validações normais, prefira:

```powershell
docker compose down
```

## CORS

O backend permite por padrão a origem local:

```text
http://localhost:8080
```

No ambiente AWS atual, o frontend acessa o backend pelo mesmo domínio do ALB usando `/api`. Em uma evolução de produção, as origens CORS devem ser restritas aos domínios autorizados.

## Arquitetura AWS Atual e Evolução

A arquitetura AWS atual foi provisionada com Terraform para o MVP de desenvolvimento. O ponto de entrada é um Application Load Balancer público em HTTP/80, encaminhando para uma EC2 privada com Docker Compose. O banco é Amazon RDS for MariaDB privado.

Fluxo atual:

```text
Usuários
-> Application Load Balancer público em subnets públicas
-> EC2 em subnet privada de aplicação executando containers Docker
-> Amazon RDS for MariaDB em subnet privada de banco
```

Componentes atuais:

- Application Load Balancer público como ponto de entrada da camada de aplicação.
- EC2 privada executando `frontend-container` e `backend-api-container`, sem tráfego direto da internet.
- RDS MariaDB privado, sem IP público e acessível somente pela aplicação.
- NAT Gateway para saída controlada da EC2 privada.
- AWS Systems Manager Session Manager para acesso administrativo à EC2.

Evolução futura:

- CloudFront, AWS WAF, AWS Shield Standard e ACM na camada de borda.
- CloudWatch para logs, métricas e alarmes.
- Secrets Manager como evolução recomendada para segredos.
- S3 como serviço auxiliar/opcional para artefatos, backups exportados ou arquivos estáticos futuros.

A execução local continua usando Docker Compose com MariaDB em container. A execução AWS usa EC2 privada com Docker Compose e RDS gerenciado.

## Infraestrutura Como Código com Terraform

A infraestrutura AWS de desenvolvimento está definida em [infra/terraform](infra/terraform/README.md). O diretório operacional é:

```text
infra/terraform/envs/dev
```

O Terraform prepara o fluxo:

```text
Usuário
-> Application Load Balancer público
-> EC2 privada com Docker
-> Amazon RDS for MariaDB privado
```

Após `terraform apply -var-file="dev.tfvars"`, a aplicação deve ficar acessível pelo output `alb_dns_name`:

```text
http://<alb_dns_name>
```

O `apply` cria recursos reais e pode gerar cobrança na AWS. Ele deve ser executado manualmente somente após revisão e autorização. Arquivos reais de variáveis, como `dev.tfvars`, não devem ser versionados. Use apenas os arquivos `*.tfvars.example` como referência.

## Documentação

- [Backend](backend/README.md)
- [Frontend](frontend/README.md)
- [Validação local](docs/validacao-local.md)
- [Checklist final do MVP](docs/checklist-mvp.md)
- [Decisões arquiteturais](docs/arquitetura/decisoes-arquiteturais.md)
- [Documentação técnica](docs/documentacao-tecnica.md)
- [Arquitetura AWS](docs/aws/arquitetura-aws.md)
- [Rede e VPC](docs/aws/rede-vpc.md)
- [EC2 com Docker](docs/aws/ec2-docker.md)
- [RDS MariaDB](docs/aws/rds-mariadb.md)
- [Segurança AWS](docs/aws/seguranca.md)
- [IAM](docs/aws/iam.md)
- [Observabilidade](docs/aws/observabilidade.md)
- [Backup e rollback](docs/aws/backup-rollback.md)
- [Validação AWS](docs/aws/validacao.md)
- [Plano de implantação AWS](docs/aws/plano-de-implantacao-aws.md)
- [Checklist AWS](docs/aws/checklist-aws.md)
- [Diagrama AWS de referência](docs/arquitetura/diagrama-aws-referencia.md)
- [Terraform](infra/terraform/README.md)

## Cuidados Operacionais

- A infraestrutura AWS gera custos enquanto estiver ativa.
- Não versionar `.env`, `dev.tfvars`, credenciais AWS, senhas ou tokens.
- Não colocar senha real em README, documentação, commits ou arquivos `*.example`.
- O arquivo `dev.tfvars` deve existir apenas localmente.
- Para encerrar o ambiente AWS após a validação, usar `terraform destroy -var-file="dev.tfvars"` a partir de `infra/terraform/envs/dev`.
- Não usar dados reais de clientes.
- Não adicionar autenticação, pagamento, logística, antifraude ou integrações externas nesta etapa.

## Próximos Passos Planejados

- Revisar e validar os diagramas finais.
- Exportar diagramas em PNG/SVG.
- Consolidar evidências de execução local.
- Revisar documentação final.
- Preparar apresentação técnica do MVP.
- Consolidar evidências da implantação AWS funcional.
