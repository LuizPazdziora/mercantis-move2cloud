# Backend

Backend funcional mínimo do MVP Mercantis Move2Cloud, construído em Python com FastAPI e persistência em MariaDB.

## Objetivo

Fornecer uma API REST simples para validar a camada de backend do MVP, incluindo health check da aplicação, health check do banco, cadastro de produtos e cadastro de pedidos. Esta etapa não inclui autenticação, pagamento, logística, antifraude ou integrações externas.

## Tecnologias usadas

- Python
- FastAPI
- SQLAlchemy
- PyMySQL
- Pydantic
- MariaDB
- Docker
- Docker Compose

## Variáveis de ambiente

| Variável | Descrição |
|---|---|
| `DB_HOST` | Host do MariaDB. No Docker Compose, use `database`. |
| `DB_PORT` | Porta do MariaDB. Padrão local: `3306`. |
| `DB_NAME` | Nome do banco de dados. |
| `DB_USER` | Usuário da aplicação no banco. |
| `DB_PASSWORD` | Senha local fictícia da aplicação. |
| `ALLOWED_ORIGINS` | Origens permitidas para CORS. |

Use `.env.example` como referência. Não versionar `.env` e não usar credenciais reais.

## Como executar localmente

A partir da raiz do repositório:

```powershell
Copy-Item .env.example .env
docker compose up --build
```

O backend ficará disponível em `http://localhost:8000`.

## Documentação Swagger

A documentação automática da API fica disponível em:

```text
http://localhost:8000/docs
```

## Endpoints disponíveis

| Método | Endpoint | Descrição |
|---|---|---|
| `GET` | `/health` | Verifica a saúde da aplicação. |
| `GET` | `/db-health` | Testa a conexão real com o MariaDB. |
| `GET` | `/products` | Lista produtos. |
| `GET` | `/products/{product_id}` | Consulta um produto por ID. |
| `POST` | `/products` | Cria um produto. |
| `PUT` | `/products/{product_id}` | Atualiza um produto. |
| `DELETE` | `/products/{product_id}` | Remove um produto. |
| `GET` | `/orders` | Lista pedidos. |
| `GET` | `/orders/{order_id}` | Consulta um pedido por ID. |
| `POST` | `/orders` | Cria um pedido. |
| `PUT` | `/orders/{order_id}` | Atualiza um pedido. |
| `DELETE` | `/orders/{order_id}` | Remove um pedido. |

## Exemplos de requisições

Criar produto:

```powershell
Invoke-RestMethod `
  -Method Post `
  -Uri http://localhost:8000/products `
  -ContentType "application/json" `
  -Body '{"name":"Teclado Mercantis","category":"Informática","price":199.90,"stock_quantity":30,"is_active":true}'
```

Listar produtos:

```powershell
Invoke-RestMethod http://localhost:8000/products
```

Criar pedido:

```powershell
Invoke-RestMethod `
  -Method Post `
  -Uri http://localhost:8000/orders `
  -ContentType "application/json" `
  -Body '{"customer_name":"Cliente Teste","product_id":1,"quantity":2,"status":"created"}'
```

Validar banco:

```powershell
Invoke-RestMethod http://localhost:8000/db-health
```

## Tratamento de erros

- Produto inexistente retorna HTTP 404.
- Pedido inexistente retorna HTTP 404.
- Pedido com produto inexistente retorna erro controlado.
- Campos `price`, `stock_quantity` e `quantity` são validados pelo Pydantic.
- `/db-health` retorna HTTP 503 quando o banco está indisponível.
