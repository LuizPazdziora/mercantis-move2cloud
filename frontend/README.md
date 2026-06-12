# Frontend

Frontend funcional do MVP Mercantis Move2Cloud, implementado com HTML, CSS e JavaScript puro, servido por Nginx em container.

## Objetivo

Disponibilizar um dashboard local para validar o consumo real da API FastAPI, acompanhar status do ambiente, listar produtos, listar pedidos e cadastrar dados fictícios para demonstração do MVP.

## Estrutura de arquivos

```text
frontend/
├── public/
│   └── index.html
├── src/
│   ├── app.js
│   └── styles.css
├── Dockerfile
├── nginx.conf
└── README.md
```

## URL local

```text
http://localhost:8080
```

## Como consome o backend

A URL base da API está centralizada em `frontend/src/app.js`:

```javascript
const API_BASE_URL = window.MERCANTIS_API_BASE_URL || "/api";
```

Por padrão, o frontend chama a API pelo caminho relativo `/api`. O Nginx do container encaminha esse prefixo para o backend em `backend:8000`.

Essa configuração mantém o ambiente local funcionando com Docker Compose e também permite a publicação na AWS via Application Load Balancer, sem depender de `localhost` no navegador do usuário externo.

Endpoints consumidos:

- `GET /health`
- `GET /db-health`
- `GET /products`
- `POST /products`
- `GET /orders`
- `POST /orders`

O frontend não acessa o MariaDB diretamente. O acesso ao banco é feito somente pelo backend usando `database:3306`.

## Funcionalidades

- Dashboard com status da API e do banco.
- Cards de total de produtos, total de pedidos, valor total em pedidos e estoque total.
- Visão geral do fluxo local `Frontend -> Backend FastAPI -> MariaDB`.
- Listagem de produtos com busca e filtro por status.
- Cadastro de produtos com validação local.
- Listagem de pedidos.
- Cadastro de pedidos com select de produtos.
- Cálculo local do total estimado do pedido.
- Feedback visual por mensagens amigáveis.
- Estados de carregamento em consultas e cadastros.
- Layout responsivo.

## Executar com Docker Compose

A partir da raiz do repositório:

```powershell
copy .env.example .env
docker compose up -d --build
```

Validar containers:

```powershell
docker compose ps
```

## CORS

O backend deve permitir a origem:

```text
http://localhost:8080
```

Esse valor está definido em `.env.example` por meio da variável `ALLOWED_ORIGINS`.

## Ambiente local

Portas esperadas:

- Frontend: `8080`
- Backend: `8000`
- MariaDB local: `3307`
- MariaDB interno no Docker: `3306`

O arquivo `.env` é necessário apenas localmente e não deve ser versionado.

## Validação

Abra no navegador:

- `http://localhost:8080`
- `http://localhost:8000/docs`

Valide no PowerShell:

```powershell
Invoke-RestMethod http://localhost:8000/health
Invoke-RestMethod http://localhost:8000/db-health
Invoke-RestMethod http://localhost:8000/products
Invoke-RestMethod http://localhost:8000/orders
```

## Observação sobre acentuação

O HTML declara `UTF-8`. Alguns terminais Windows podem exibir caracteres acentuados de forma incorreta mesmo quando a resposta HTTP e os arquivos estão em UTF-8. A validação visual deve ser feita preferencialmente no navegador.
