# Backend

Backend funcional mínimo do MVP Mercantis Move2Cloud, construído em Python com FastAPI e persistência em MariaDB.

## Objetivo

Fornecer uma API REST para validar a camada de aplicação do MVP, incluindo health check da aplicação, health check real do banco, CRUD de produtos e CRUD de pedidos simulados.

Esta etapa não inclui autenticação, pagamento, logística, antifraude ou integrações externas.

## Stack

- Python
- FastAPI
- SQLAlchemy
- PyMySQL
- Pydantic
- MariaDB
- Docker Compose

## Variáveis de ambiente

| Variável | Descrição |
|---|---|
| `DB_HOST` | Host do MariaDB. No Docker Compose, use `database`. |
| `DB_PORT` | Porta interna do MariaDB usada pelo backend. Padrão: `3306`. |
| `DB_PORT_LOCAL` | Porta publicada no host local para ferramentas externas. Padrão: `3307`. |
| `DB_NAME` | Nome do banco de dados. |
| `DB_USER` | Usuário local da aplicação no banco. |
| `DB_PASSWORD` | Senha local fictícia da aplicação. |
| `DB_ROOT_PASSWORD` | Senha local fictícia do root do MariaDB. |
| `ALLOWED_ORIGINS` | Origens permitidas para CORS. Padrão: `http://localhost:8080`. |

Use `.env.example` como referência. Não versionar `.env` e não usar credenciais reais.

## Execução local

A partir da raiz do repositório:

```powershell
copy .env.example .env
docker compose up -d --build
```

O backend ficará disponível em:

```text
http://localhost:8000
```

## Swagger

Documentação automática:

```text
http://localhost:8000/docs
```

## Endpoints

| Método | Endpoint | Descrição |
|---|---|---|
| `GET` | `/health` | Verifica a saúde da aplicação. |
| `GET` | `/db-health` | Testa a conexão real com o MariaDB. |
| `GET` | `/products` | Lista produtos. |
| `GET` | `/products/{product_id}` | Consulta produto por ID. |
| `POST` | `/products` | Cria produto. |
| `PUT` | `/products/{product_id}` | Atualiza produto. |
| `DELETE` | `/products/{product_id}` | Remove produto. |
| `GET` | `/orders` | Lista pedidos. |
| `GET` | `/orders/{order_id}` | Consulta pedido por ID. |
| `POST` | `/orders` | Cria pedido. |
| `PUT` | `/orders/{order_id}` | Atualiza pedido. |
| `DELETE` | `/orders/{order_id}` | Remove pedido. |

## Validação

```powershell
Invoke-RestMethod http://localhost:8000/health
Invoke-RestMethod http://localhost:8000/db-health
Invoke-RestMethod http://localhost:8000/products
Invoke-RestMethod http://localhost:8000/orders
```

Resultado esperado:

- `/health` retorna `status: ok`.
- `/db-health` retorna `status: ok` quando o banco está disponível.
- `/products` retorna lista de produtos.
- `/orders` retorna lista de pedidos.

## Exemplos

Criar produto:

```powershell
Invoke-RestMethod `
  -Method Post `
  -Uri http://localhost:8000/products `
  -ContentType "application/json" `
  -Body '{"name":"Teclado Mercantis","category":"Informática","price":199.90,"stock_quantity":30,"is_active":true}'
```

Criar pedido:

```powershell
Invoke-RestMethod `
  -Method Post `
  -Uri http://localhost:8000/orders `
  -ContentType "application/json" `
  -Body '{"customer_name":"Cliente Teste","product_id":1,"quantity":2,"status":"created"}'
```

## Tratamento de erros

- Produto inexistente retorna HTTP 404.
- Pedido inexistente retorna HTTP 404.
- Pedido com produto inexistente retorna erro controlado.
- Valores inválidos são tratados por validação Pydantic.
- `/db-health` retorna HTTP 503 quando o banco está indisponível.
- Stack traces não são exibidos ao usuário final.

## MariaDB

O backend acessa o banco pela rede Docker:

```text
database:3306
```

A porta local `3307` é usada apenas para acesso a partir da máquina local.

## CORS

O backend permite por padrão a origem:

```text
http://localhost:8080
```

Os métodos permitidos são `GET`, `POST`, `PUT`, `DELETE` e `OPTIONS`. Em uma futura implantação AWS, a lista de origens deve ser atualizada para os domínios autorizados.

## Acentuação e UTF-8

O backend usa PyMySQL com `charset=utf8mb4`. O MariaDB é iniciado com `utf8mb4` e collation `utf8mb4_unicode_ci`.

Alguns terminais Windows podem exibir acentos de forma incorreta. A validação visual principal deve ser feita no navegador:

- `http://localhost:8000/docs`
- `http://localhost:8080`
