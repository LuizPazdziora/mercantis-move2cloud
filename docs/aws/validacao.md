# Validação

## Validação local

- `docker compose config` executa sem erro com variáveis locais definidas.
- Serviços `frontend`, `backend` e `database` são criados.
- Endpoint `GET /health` responde com status `ok`.
- Frontend abre em `http://localhost:8080`.
- Backend abre em `http://localhost:8000`.
- MariaDB inicia com scripts de `database/init.sql` e `database/seed.sql`.

## Validação AWS futura

- RDS permanece sem IP público.
- Backend acessa o banco pela porta 3306.
- Usuários externos não acessam banco nem instâncias privadas diretamente.
- Tráfego público usa HTTPS.
- Logs básicos são coletados.
- Custos são acompanhados durante a janela de validação.

## Evidências esperadas

- Captura do endpoint `/health`.
- Captura do frontend.
- Registro do estado dos containers.
- Registro das regras de Security Groups.
- Registro da configuração privada do RDS.
