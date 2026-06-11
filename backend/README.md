# Backend

API inicial do Mercantis Move2Cloud, construída em Python com FastAPI.

## Escopo atual

- Endpoint básico `GET /health`.
- Estrutura inicial para rotas de produtos e pedidos.
- Preparação para conexão com MariaDB por variáveis de ambiente.
- Sem autenticação, pagamento, logística ou regras comerciais completas nesta etapa.

## Execução local

O backend deve ser executado pelo `docker-compose.yml` da raiz do repositório.

```powershell
docker compose up --build backend
```

As variáveis esperadas estão documentadas em `.env.example`.
