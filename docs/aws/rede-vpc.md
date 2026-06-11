# Rede e VPC

Este documento define a proposta de rede AWS para o Mercantis Move2Cloud. A proposta e uma referencia tecnica e nao cria recursos reais.

## Proposta de VPC

CIDR sugerido:

```text
10.0.0.0/16
```

Esse bloco oferece espaco suficiente para separar subnets publicas e privadas, manter crescimento controlado e evitar sobreposicao com redes comuns de laboratorio local.

## Subnets sugeridas

| Subnet | CIDR | Papel |
| --- | --- | --- |
| Public Subnet A | `10.0.1.0/24` | Entrada publica controlada |
| Public Subnet B | `10.0.2.0/24` | Redundancia e evolucao |
| Private Subnet A | `10.0.11.0/24` | RDS privado |
| Private Subnet B | `10.0.12.0/24` | RDS privado e evolucao Multi-AZ |

As subnets devem ser distribuidas em pelo menos duas zonas de disponibilidade. Para o RDS, isso e importante porque o DB subnet group precisa de subnets em zonas diferentes e porque uma evolucao para Multi-AZ exige isolamento entre zonas.

## Subnet publica e subnet privada

Uma subnet publica possui rota para o Internet Gateway e pode hospedar recursos que precisam receber trafego externo controlado. Uma subnet privada nao recebe entrada direta da internet e deve hospedar recursos internos, como banco de dados.

No MVP de referencia, a EC2 pode ficar em subnet publica para simplificar a validacao. A evolucao mais segura e usar um Load Balancer publico e manter as instancias EC2 em subnets privadas.

## Internet Gateway

O Internet Gateway conecta a VPC a internet. Ele deve ser associado a VPC, e apenas as route tables das subnets publicas devem conter rota padrao para ele.

## Route Tables

### Route Table publica

Rota esperada:

```text
0.0.0.0/0 -> Internet Gateway
```

Essa tabela deve ser associada somente as subnets publicas.

### Route Table privada

A tabela privada deve manter o trafego interno da VPC e nao deve expor o RDS diretamente. Uma rota de saida por NAT pode ser considerada em etapas futuras, se recursos privados precisarem acessar a internet para atualizacoes ou integracoes.

## Posicionamento do RDS

O Amazon RDS for MariaDB deve ficar em subnets privadas, com `Public accessibility` desabilitado. O acesso deve ser permitido apenas pela porta `3306` a partir do Security Group da EC2.

## Posicionamento da EC2

Para o MVP, a EC2 pode ficar em subnet publica, com Security Group restritivo. Em uma arquitetura mais madura:

- o Load Balancer fica em subnets publicas;
- a EC2 fica em subnets privadas;
- o RDS permanece em subnets privadas;
- o acesso administrativo passa por SSM Session Manager ou bastion controlado.

## Regras de desenho

- O banco nao deve ter rota direta para internet.
- A porta `3306` nao deve ser aberta para `0.0.0.0/0`.
- SSH, se habilitado, deve ser restrito a IPs autorizados.
- A exposicao publica deve usar HTTPS antes de qualquer liberacao real.
