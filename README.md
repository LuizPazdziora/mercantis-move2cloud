# Mercantis Move2Cloud

O Mercantis Move2Cloud é um MVP de aplicação web voltado a arquitetura AWS, segurança, documentação técnica e demonstração funcional mínima. A estratégia arquitetural definida é replatform com refactor parcial: a aplicação passa a ser preparada em containers e o banco de dados de produção é planejado como Amazon RDS for MariaDB em subnet privada.

Esta etapa cria apenas a estrutura inicial do projeto. O objetivo é permitir evolução segura nas próximas tarefas, sem implementar todos os fluxos de negócio e sem publicar ambiente online.

## Arquitetura geral

O ambiente local é composto por três serviços em Docker Compose:

- `frontend`: interface web simples e containerizada.
- `backend`: API em Python com FastAPI.
- `database`: MariaDB local para desenvolvimento.

Fluxo local:

```text
Navegador -> frontend -> backend FastAPI -> MariaDB
```

Para AWS, a referência futura mantém o banco em Amazon RDS for MariaDB privado, com acesso permitido somente pela camada de backend. Nenhuma implantação pública deve ser mantida sem validação, revisão de segurança e liberação explícita.

## Como executar localmente

Pré-requisitos:

- Docker
- Docker Compose

Comandos:

```powershell
cd "C:\Users\lfpaz\OneDrive\Documentos\New project\mercantis-move2cloud"
Copy-Item .env.example .env
docker compose up --build
```

Após a subida dos containers:

- Frontend: `http://localhost:8080`
- Backend: `http://localhost:8000`
- Health check: `http://localhost:8000/health`

O arquivo `.env` criado localmente não deve ser versionado. Use apenas valores locais de desenvolvimento e nunca credenciais reais.

## Estrutura principal

- `backend/`: API FastAPI.
- `frontend/`: frontend inicial containerizado.
- `database/`: scripts SQL iniciais.
- `docs/`: documentação técnica em português.
- `infra/aws-reference/`: referências de arquitetura AWS para evolução.
- `docker-compose.yml`: orquestração local.
- `.env.example`: exemplo de variáveis de ambiente sem secrets reais.
- `codex-instructions.md`: decisões técnicas para orientar próximas tarefas.

## Documentação

- [Documentação técnica](docs/documentacao-tecnica.md)
- [Decisões arquiteturais](docs/arquitetura/decisoes-arquiteturais.md)
- [Diagrama do MVP](docs/arquitetura/diagrama-mvp.md)
- [Diagrama de referência final](docs/arquitetura/diagrama-final.md)
- [Plano de implantação AWS](docs/aws/plano-de-implantacao-aws.md)
- [Segurança](docs/aws/seguranca.md)
- [Validação](docs/aws/validacao.md)

## Restrições

- Não versionar `.env`.
- Não criar credenciais reais no repositório.
- Não usar dados reais de clientes no MVP.
- Não implementar pagamento real, logística, antifraude ou estoque real nesta etapa.
- Não publicar ambiente AWS sem liberação explícita.
