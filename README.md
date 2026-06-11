# Mercantis Move2Cloud

O Mercantis Move2Cloud é um MVP de aplicação web containerizada para validar uma base técnica de migração para AWS. O projeto usa a estratégia de replatform com refactor parcial: a aplicação é organizada em containers e o banco de produção é planejado como Amazon RDS for MariaDB em subnet privada.

O ambiente atual é local, executado com Docker Compose, e não cria recursos reais na AWS.

## Status atual do MVP

- Frontend funcional em `http://localhost:8080`.
- Backend FastAPI em `http://localhost:8000`.
- Swagger em `http://localhost:8000/docs`.
- MariaDB em container Docker.
- MariaDB interno em `3306`.
- MariaDB publicado localmente em `127.0.0.1:3307`.
- Fluxo validado: `Frontend -> Backend FastAPI -> MariaDB`.

## Arquitetura local

```text
Navegador
-> frontend / Nginx / porta 8080
-> backend / FastAPI / porta 8000
-> database / MariaDB / database:3306
```

O frontend não acessa o banco diretamente. A comunicação com o MariaDB é feita somente pelo backend usando o host interno `database` e a porta `3306`.

## Tecnologias

- HTML, CSS e JavaScript puro no frontend.
- Nginx para servir o frontend.
- Python com FastAPI no backend.
- SQLAlchemy e PyMySQL para acesso ao banco.
- Pydantic para validação de entrada e saída.
- MariaDB como banco local.
- Docker Compose para orquestração local.

## Estrutura de pastas

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

## Configurar variáveis de ambiente

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

## Subir o ambiente

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

## URLs locais

- Frontend: `http://localhost:8080`
- Backend Swagger: `http://localhost:8000/docs`
- API Health: `http://localhost:8000/health`
- DB Health: `http://localhost:8000/db-health`
- Produtos: `http://localhost:8000/products`
- Pedidos: `http://localhost:8000/orders`

## Validação rápida

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

Em uma implantação futura na AWS, as origens CORS devem ser restritas aos domínios autorizados.

## Arquitetura AWS de Referência

A arquitetura AWS de referência foi documentada para orientar uma implantação futura simples, segura e controlada. Nenhum recurso real foi criado na AWS nesta etapa, a aplicação não foi publicada online e não foram geradas credenciais reais.

A estratégia permanece como replatform com refactor parcial:

- frontend e backend continuam containerizados;
- a EC2 é usada como host Docker no MVP AWS;
- o MariaDB local é substituído por Amazon RDS for MariaDB;
- o RDS fica em subnet privada;
- Security Groups segmentam acesso entre internet, EC2 e banco;
- Secrets Manager e CloudWatch são recomendações de evolução.

Documentos principais:

- [Arquitetura AWS](docs/aws/arquitetura-aws.md)
- [Rede e VPC](docs/aws/rede-vpc.md)
- [EC2 com Docker](docs/aws/ec2-docker.md)
- [RDS MariaDB](docs/aws/rds-mariadb.md)
- [Segurança AWS](docs/aws/seguranca.md)
- [IAM](docs/aws/iam.md)
- [Observabilidade](docs/aws/observabilidade.md)
- [Backup e rollback](docs/aws/backup-rollback.md)
- [Plano de implantação AWS](docs/aws/plano-de-implantacao-aws.md)
- [Checklist AWS](docs/aws/checklist-aws.md)
- [Diagrama AWS de referência](docs/arquitetura/diagrama-aws-referencia.md)

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
- [IAM](docs/aws/iam.md)
- [Observabilidade](docs/aws/observabilidade.md)
- [Backup e rollback](docs/aws/backup-rollback.md)
- [Plano de implantação AWS](docs/aws/plano-de-implantacao-aws.md)
- [Segurança AWS](docs/aws/seguranca.md)
- [Checklist AWS](docs/aws/checklist-aws.md)

## Restrições atuais

- Não criar recursos reais na AWS.
- Não publicar a aplicação online sem liberação explícita.
- Não versionar `.env`.
- Não usar credenciais reais.
- Não usar dados reais de clientes.
- Não adicionar autenticação, pagamento, logística, antifraude ou integrações externas nesta etapa.

## Próximos passos planejados

- Detalhar arquitetura AWS de referência com VPC, subnets e Security Groups.
- Planejar Amazon RDS for MariaDB em subnet privada.
- Definir estratégia de secrets para AWS.
- Documentar observabilidade, backup, validação de segurança e plano de desativação de recursos temporários.
