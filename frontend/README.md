# Frontend

Frontend inicial e estático do Mercantis Move2Cloud, preparado para execução em container.

## Escopo atual

- Página mínima de apresentação do MVP.
- Verificação simples do endpoint `GET /health` do backend local.
- Sem catálogo, carrinho ou checkout implementados nesta etapa.

## Execução local

O frontend deve ser executado pelo `docker-compose.yml` da raiz do repositório.

```powershell
docker compose up --build frontend
```

Por padrão, a aplicação fica disponível em `http://localhost:8080`.
