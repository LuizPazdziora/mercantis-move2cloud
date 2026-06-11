# Mercantis Move2Cloud - Roadmap

## Fase 1 - Estrutura inicial local

- Criar estrutura do backend FastAPI.
- Criar frontend simples containerizado.
- Configurar MariaDB local com Docker Compose.
- Criar documentação técnica inicial.
- Criar endpoint `/health`.

## Fase 2 - MVP funcional mínimo

- Evoluir catálogo de produtos fictícios.
- Criar fluxo simplificado de pedidos simulados.
- Persistir dados de demonstração no MariaDB.
- Adicionar testes automatizados essenciais.
- Melhorar tratamento de erros e validações.

## Fase 3 - Preparação AWS controlada

- Detalhar VPC, subnets e Security Groups.
- Planejar Amazon RDS for MariaDB em subnet privada.
- Definir entrada HTTPS controlada.
- Validar logs, métricas e auditoria.
- Documentar plano de desligamento de recursos temporários.

## Fase 4 - Operação assistida

- Revisar segurança antes de qualquer exposição externa.
- Definir processo de deploy e rollback.
- Validar custos estimados.
- Registrar evidências técnicas.
- Formalizar critérios de liberação.
