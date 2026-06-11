# Instruções do Projeto para o Codex

## Decisões técnicas obrigatórias

- Trabalhar sempre na raiz do repositório `mercantis-move2cloud`.
- Manter o backend em Python com FastAPI.
- Manter o frontend simples e containerizado.
- Usar MariaDB no ambiente local.
- Usar Docker Compose para desenvolvimento local.
- Planejar o banco de produção como Amazon RDS for MariaDB em subnet privada.
- Não criar, versionar ou expor credenciais reais.
- Usar variáveis de ambiente para configuração.
- Manter `.env.example` como referência e não criar `.env` com valores reais.
- Escrever toda documentação em português do Brasil, com tom técnico e profissional.
- Não publicar ambiente AWS ou recursos públicos sem liberação explícita.
- Não adicionar Kubernetes, ECS, Lambda ou API Gateway nesta etapa.

## Estratégia arquitetural

A estratégia definida é replatform com refactor parcial. O banco evolui para serviço gerenciado no Amazon RDS for MariaDB, enquanto frontend e backend são preparados para execução em containers. A primeira base local deve validar a separação entre frontend, API e banco sem implementar fluxos comerciais completos.

## Limites de escopo atuais

- Criar apenas a estrutura inicial do projeto.
- Implementar somente o endpoint básico `/health`.
- Deixar rotas de produtos e pedidos como pontos de evolução.
- Não implementar pagamento real, logística, antifraude, estoque real ou painel administrativo completo.
- Não usar dados reais de clientes.
