# Módulo Network

Este módulo cria a base de rede AWS do ambiente dev do Mercantis Move2Cloud.

## Recursos

- VPC `10.0.0.0/16`.
- Subnets públicas para ALB e NAT Gateway.
- Subnets privadas de aplicação para EC2.
- Subnets privadas de banco para RDS.
- Internet Gateway.
- Elastic IP e NAT Gateway.
- Route Tables públicas, privadas de aplicação e privadas de banco.
- Associações entre subnets e Route Tables.

## Observações

A EC2 da aplicação permanece em subnet privada. O ALB e o NAT Gateway ficam nas subnets públicas. O RDS fica nas subnets privadas de banco, sem rota pública para internet.
