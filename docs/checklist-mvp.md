# Checklist Final do MVP

## Aplicação

- [ ] Frontend abre em `http://localhost:8080`.
- [ ] Dashboard exibe status da API.
- [ ] Dashboard exibe status do banco.
- [ ] Fluxo local `Frontend -> Backend FastAPI -> MariaDB` está validado.
- [ ] Nenhum recurso AWS real foi criado.

## Backend

- [ ] Backend responde em `http://localhost:8000/health`.
- [ ] Banco responde via `http://localhost:8000/db-health`.
- [ ] Produtos são listados em `GET /products`.
- [ ] Pedidos são listados em `GET /orders`.
- [ ] Produto inexistente retorna HTTP 404.
- [ ] Pedido inexistente retorna HTTP 404.
- [ ] Pedido com produto inexistente retorna erro controlado.
- [ ] Valores inválidos são tratados por validação Pydantic.
- [ ] Swagger abre em `http://localhost:8000/docs`.

## Frontend

- [ ] Produtos são listados no frontend.
- [ ] Pedidos são listados no frontend.
- [ ] Produto pode ser cadastrado pelo frontend.
- [ ] Pedido pode ser cadastrado pelo frontend.
- [ ] Lista de produtos atualiza após cadastro.
- [ ] Lista de pedidos atualiza após cadastro.
- [ ] Mensagens de erro são amigáveis.
- [ ] Layout é responsivo para telas menores.

## Banco de Dados

- [ ] MariaDB está saudável no Docker Compose.
- [ ] MariaDB usa porta interna `3306`.
- [ ] MariaDB usa porta local `3307`.
- [ ] Backend acessa banco por `database:3306`.
- [ ] Banco usa charset `utf8mb4`.
- [ ] Seed usa dados fictícios.

## Docker

- [ ] `docker compose up -d --build` executa com sucesso.
- [ ] `docker compose ps` mostra containers em execução.
- [ ] Backend depende do database com healthcheck.
- [ ] Database possui healthcheck.
- [ ] Frontend depende do backend iniciado.
- [ ] Não foi executado `docker compose down -v` sem necessidade.

## Segurança

- [ ] `.env` não está versionado.
- [ ] `.env.example` usa valores fictícios.
- [ ] MariaDB não usa senha real no repositório.
- [ ] Credenciais reais não foram criadas.
- [ ] CORS permite o frontend local `http://localhost:8080`.
- [ ] Banco não é acessado diretamente pelo frontend.

## Documentação

- [ ] README principal está atualizado.
- [ ] `backend/README.md` está atualizado.
- [ ] `frontend/README.md` está atualizado.
- [ ] `docs/validacao-local.md` existe.
- [ ] `docs/arquitetura/decisoes-arquiteturais.md` está atualizado.
- [ ] Problemas comuns estão documentados.

## Preparação AWS

- [ ] Banco em produção planejado como Amazon RDS for MariaDB privado.
- [ ] Estratégia de migração documentada como replatform com refactor parcial.
- [ ] Nenhuma publicação online foi feita.
- [ ] Próxima etapa AWS deve começar por desenho de VPC, subnets e Security Groups.
