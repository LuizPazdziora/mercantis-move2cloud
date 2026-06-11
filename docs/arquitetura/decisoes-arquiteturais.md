# Decisões Arquiteturais

## Estratégia de migração

A estratégia definida para o Mercantis Move2Cloud é replatform com refactor parcial. A aplicação será preparada em containers, enquanto o banco de dados planejado para produção será Amazon RDS for MariaDB em subnet privada.

## Decisões técnicas

- Backend em Python com FastAPI.
- Frontend simples containerizado.
- Banco de dados MariaDB no ambiente local.
- Desenvolvimento local com Docker Compose.
- Configuração por variáveis de ambiente.
- Documentação em português do Brasil.
- Nenhuma credencial real versionada.
- Ambiente AWS somente após validação e liberação explícita.

## Decisões de segurança

- Banco sem acesso público.
- Frontend sem acesso direto ao banco.
- Backend como única camada autorizada a acessar MariaDB.
- Uso de `.env.example` como referência de configuração.
- Proibição de secrets reais, tokens e chaves AWS no repositório.

## Fora do escopo nesta etapa

- Pagamento real.
- Integração logística.
- Antifraude.
- Dados reais de clientes.
- Painel administrativo completo.
- Kubernetes, ECS, Lambda ou API Gateway.
