# Documentação Técnica

## Objetivo

O Mercantis Move2Cloud é um MVP de aplicação web com foco em arquitetura AWS, segurança, documentação técnica e demonstração funcional mínima. A base atual cria a estrutura inicial para evolução do projeto, mantendo separação entre frontend, backend e banco de dados.

## Arquitetura local

O ambiente local usa Docker Compose com três serviços:

- `frontend`: interface web simples servida por Nginx.
- `backend`: API FastAPI em Python.
- `database`: MariaDB para desenvolvimento local.

## Arquitetura AWS planejada

A implantação AWS futura deve seguir a estratégia de replatform com refactor parcial. O banco de dados deve ser Amazon RDS for MariaDB em subnet privada. A aplicação deve permanecer em camada privada sempre que possível, com entrada pública controlada e somente após liberação explícita.

## Escopo implementado nesta base

- Estrutura de diretórios do backend.
- Estrutura de diretórios do frontend.
- Dockerfile para backend e frontend.
- Docker Compose com frontend, backend e database.
- Scripts iniciais de banco.
- Endpoint `/health`.
- Documentação técnica inicial.

## Limites

- Não há pagamento real.
- Não há integração logística.
- Não há antifraude.
- Não há estoque real.
- Não há dados reais de clientes.
- Não há ambiente AWS publicado por este repositório.
