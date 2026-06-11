# Mercantis Move2Cloud - Documentação Técnica

Este arquivo preserva o ponto de entrada documental já existente no repositório e consolida a orientação atual da base inicial.

## Objetivo

O Mercantis Move2Cloud é um MVP de aplicação web para demonstrar uma arquitetura inicial com frontend containerizado, backend FastAPI e banco MariaDB. A evolução planejada para AWS segue a estratégia de replatform com refactor parcial, com banco de produção previsto em Amazon RDS for MariaDB em subnet privada.

## Escopo atual

- Estrutura inicial de backend, frontend, banco, documentação e referências de infraestrutura.
- Execução local com Docker Compose.
- Endpoint básico `GET /health`.
- Preparação para variáveis de ambiente.
- Documentação técnica em português do Brasil.

## Fora do escopo atual

- Pagamento real.
- Integração logística.
- Antifraude.
- Estoque real.
- Dados reais de clientes.
- Painel administrativo completo.
- Publicação automática em AWS.

## Referências internas

- [Documentação técnica atual](documentacao-tecnica.md)
- [Decisões arquiteturais](arquitetura/decisoes-arquiteturais.md)
- [Plano de implantação AWS](aws/plano-de-implantacao-aws.md)
- [Segurança](aws/seguranca.md)
- [Validação](aws/validacao.md)

## Diretrizes de segurança

- Nenhuma credencial real deve ser versionada.
- O arquivo `.env.example` serve apenas como referência.
- O arquivo `.env` deve permanecer local e fora do Git.
- O banco em AWS deve permanecer privado.
- O acesso ao banco deve ser feito somente pelo backend.
- O ambiente online depende de liberação explícita.
