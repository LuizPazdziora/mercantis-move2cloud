# Mercantis Move2Cloud

Documentação técnica da primeira entrega do projeto **Mercantis Move2Cloud — Infraestrutura em Nuvem AWS**.

## Objetivo

Apresentar a proposta de migração do ambiente de e-commerce da Mercantis para AWS, documentando o cenário atual, os problemas do ambiente AS-IS, a estratégia de migração, a arquitetura do MVP, a arquitetura final TO-BE, os controles de segurança, os Security Groups, os SLOs, o plano de operação, o plano de descomissionamento e o roadmap de evolução.

## Escopo da primeira entrega

Esta entrega tem foco em documentação, arquitetura, segurança e planejamento técnico. O MVP descrito valida a infraestrutura e a integração entre frontend, backend/API em containers Docker e Amazon RDS for MariaDB privado, mas não representa uma loja virtual real em produção.

O escopo não inclui pagamento real, integração logística, antifraude, dados reais de clientes, nota fiscal, estoque real ou painel administrativo completo.

## Documentação

- [Documentação técnica completa](docs/mercantis-move2cloud-documentacao.md)
- [Security Groups](docs/security-groups.md)
- [Checklist de segurança Dia 1](docs/checklist-dia-1.md)
- [Roadmap](docs/roadmap.md)

## Diagramas

- [Diagrama da infraestrutura do MVP](docs/images/diagrama-mvp.png)
- [Diagrama da infraestrutura final TO-BE](docs/images/diagrama-final-to-be.png)
- [Fonte do diagrama final TO-BE](infra/diagrams/diagrama-final-to-be.svg)

## Aviso operacional

O MVP é um ambiente temporário para testes, validação técnica e demonstração acadêmica. Ele não deve permanecer online após os testes sem liberação formal, revisão de segurança, controle de custos e execução do plano de operação aprovado.
