# Validação Local do MVP

## Objetivo

Este documento descreve o roteiro de validação local do Mercantis Move2Cloud. O foco é confirmar que o MVP executa com Docker Compose, que o frontend consome o backend FastAPI e que o backend acessa o MariaDB pela rede interna Docker.

## Pré-requisitos

- Docker instalado e em execução.
- Docker Compose disponível.
- Repositório clonado localmente.
- Arquivo `.env` criado a partir de `.env.example`.

Criação do `.env` no Windows PowerShell:

```powershell
copy .env.example .env
```

Alternativa multiplataforma:

```bash
cp .env.example .env
```

O arquivo `.env` é local, não deve ser versionado e não deve conter credenciais reais.

## Subir o ambiente

```powershell
docker compose up -d --build
```

## Verificar containers

```powershell
docker compose ps
```

Resultado esperado:

- `mercantis-frontend` em execução, publicado em `http://localhost:8080`.
- `mercantis-backend` em execução, publicado em `http://localhost:8000`.
- `mercantis-database` em execução e `healthy`.
- MariaDB publicado localmente em `127.0.0.1:3307->3306/tcp`.

## Validar API no PowerShell

```powershell
Invoke-RestMethod http://localhost:8000/health
Invoke-RestMethod http://localhost:8000/db-health
Invoke-RestMethod http://localhost:8000/products
Invoke-RestMethod http://localhost:8000/orders
```

Resultados esperados:

| Validação | Resultado esperado |
|---|---|
| `/health` | Retorna `status: ok` e `service: mercantis-backend`. |
| `/db-health` | Retorna `status: ok` quando o MariaDB está acessível. |
| `/products` | Retorna lista de produtos fictícios do MVP. |
| `/orders` | Retorna lista de pedidos simulados. |

## Validar no navegador

Abra:

- `http://localhost:8080`
- `http://localhost:8000/docs`

Resultados esperados:

- O frontend exibe dashboard com status da API, status do banco, produtos e pedidos.
- A documentação Swagger abre em `/docs`.
- A acentuação deve ser validada preferencialmente no navegador.

## Problemas comuns

### Ausência de `.env`

Sintoma: Docker Compose informa que variáveis como `DB_NAME`, `DB_USER`, `DB_PASSWORD` ou `DB_ROOT_PASSWORD` não foram definidas.

Correção:

```powershell
copy .env.example .env
```

### Porta 3306 ocupada

O MariaDB interno usa a porta `3306`, mas a porta publicada no host local é `3307`.

Use:

```env
DB_PORT=3306
DB_PORT_LOCAL=3307
```

Se uma ferramenta local precisar acessar o banco, conecte em `127.0.0.1:3307`.

### Necessidade de usar 3307

Use `3307` somente para acesso a partir da máquina local, por exemplo DBeaver, MySQL Workbench ou terminal. O backend usa `database:3306` pela rede Docker.

### Volume MariaDB antigo

Os scripts em `database/init.sql` e `database/seed.sql` são aplicados automaticamente apenas na criação inicial do volume. Se o volume já existia, alterações nesses scripts podem não refletir no banco local existente.

### Quando usar `docker compose down -v`

Use `docker compose down -v` somente quando for aceitável apagar todos os dados locais do MariaDB e recriar o banco do zero. Esse comando remove volumes e deve ser evitado quando houver dados locais que precisam ser preservados.

## Encerramento local

Para parar os containers sem remover volumes:

```powershell
docker compose down
```

Não use `docker compose down -v` em validações normais.
