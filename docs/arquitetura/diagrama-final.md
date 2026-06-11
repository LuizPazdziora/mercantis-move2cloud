# Diagrama de Referência Final

A visão final prevista nesta etapa mantém a separação entre borda, aplicação e banco de dados, sem implantação pública automática.

## Componentes de referência

- VPC dedicada na região definida para o projeto.
- Subnets públicas para recursos de entrada controlada.
- Subnets privadas para aplicação.
- Subnets privadas para banco de dados.
- Backend acessando o banco pela porta 3306.
- Amazon RDS for MariaDB sem IP público.
- Observabilidade e auditoria com serviços AWS apropriados para logs e rastreabilidade.

## Fluxo alvo

```text
Usuário
-> entrada HTTPS controlada
-> camada de aplicação privada
-> backend FastAPI
-> Amazon RDS for MariaDB privado
```

Imagem de referência preservada no repositório:

![Diagrama Final](../images/diagrama-final-to-be.png)
