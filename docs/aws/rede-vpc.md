# Rede e VPC

Este documento descreve a rede AWS de referência para o Mercantis Move2Cloud, alinhada ao diagrama de infraestrutura do MVP. A proposta é documental e não cria recursos reais.

## Região

Região de referência:

```text
sa-east-1 - São Paulo
```

## VPC

CIDR sugerido:

```text
10.0.0.0/16
```

Esse bloco permite separar subnets públicas, subnets privadas de aplicação e subnets privadas de banco, mantendo espaço para expansão futura.

## Subnets Sugeridas

| Camada | Subnet | CIDR | Uso |
| --- | --- | --- | --- |
| Pública | Public Subnet 1A | `10.0.1.0/24` | ALB e NAT Gateway |
| Pública | Public Subnet 1B | `10.0.2.0/24` | ALB e expansão |
| Privada de aplicação | Private App Subnet 1A | `10.0.11.0/24` | EC2 com Docker no MVP |
| Privada de aplicação | Private App Subnet 1B | `10.0.12.0/24` | Expansão futura e alta disponibilidade |
| Privada de banco | Private DB Subnet 1A | `10.0.21.0/24` | RDS MariaDB |
| Privada de banco | Private DB Subnet 1B | `10.0.22.0/24` | DB Subnet Group e evolução Multi-AZ |

## Subnets Públicas

As subnets públicas recebem recursos que precisam de conectividade pública controlada:

- Application Load Balancer.
- NAT Gateway.
- Rota para o Internet Gateway.

A aplicação não deve ser executada diretamente nessas subnets no desenho atual.

## Subnets Privadas de Aplicação

As subnets privadas de aplicação recebem a EC2 que executa Docker. A EC2 não recebe tráfego direto da internet. O acesso externo chega ao ALB e, a partir dele, segue para a EC2 por Security Group.

A subnet `10.0.12.0/24` fica reservada para expansão futura, como segunda EC2, Auto Scaling ou maior disponibilidade.

## Subnets Privadas de Banco

As subnets privadas de banco recebem o Amazon RDS for MariaDB por meio de um DB Subnet Group. O RDS deve usar subnets em mais de uma zona de disponibilidade, mesmo que o MVP comece com implantação simples.

O RDS deve permanecer sem IP público e sem rota direta para internet.

## Internet Gateway

O Internet Gateway conecta a VPC à internet. Ele atende a camada pública, especialmente CloudFront/ALB indiretamente e rotas públicas associadas às subnets públicas.

## NAT Gateway

O NAT Gateway permite saída controlada da EC2 privada para atualizações de sistema, downloads de pacotes e dependências operacionais. Ele não permite conexões iniciadas da internet para a EC2.

No MVP, pode haver apenas um NAT Gateway para reduzir custo e complexidade. Em ambiente produtivo com alta disponibilidade, recomenda-se um NAT Gateway por zona de disponibilidade.

## Route Tables

### Route Table Pública

Rota esperada:

```text
0.0.0.0/0 -> Internet Gateway
```

Associada às subnets públicas.

### Route Table Privada de Aplicação

Rota esperada para saída controlada:

```text
0.0.0.0/0 -> NAT Gateway
```

Associada às subnets privadas de aplicação, quando a EC2 precisar acessar a internet para atualizações ou downloads.

### Route Table Privada de Banco

Não deve ter rota direta para Internet Gateway. Em geral, o RDS precisa apenas de comunicação privada com a aplicação.

## Regras de Desenho

- ALB em subnets públicas.
- EC2 em subnet privada de aplicação.
- RDS em subnets privadas de banco.
- EC2 sem tráfego direto da internet.
- RDS sem IP público.
- Porta `3306` permitida apenas do Security Group da aplicação para o Security Group do RDS.
- SSH bloqueado ou fortemente restrito.
- Session Manager recomendado para acesso administrativo futuro.
