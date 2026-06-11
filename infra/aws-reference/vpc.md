# Referência de VPC

## Objetivo

Definir uma rede AWS segregada por camadas para futura implantação controlada do Mercantis Move2Cloud.

## Estrutura sugerida

- VPC dedicada para o projeto.
- Subnets públicas para entrada controlada.
- Subnets privadas de aplicação.
- Subnets privadas de banco de dados.
- Tabelas de rota separadas por camada.

## Diretrizes

- Banco de dados sem rota pública.
- Aplicação sem acesso direto de usuários externos.
- Saída para internet apenas quando necessária para operação, atualização e coleta de logs.
- Nomes e CIDRs devem ser confirmados antes da implantação.
