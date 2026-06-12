# Segurança

Este documento descreve os controles de segurança do ambiente AWS de desenvolvimento do Mercantis Move2Cloud e as recomendações de evolução para uma publicação mais robusta.

## Princípios

- Menor privilégio para acessos humanos e técnicos.
- Separação de camadas por rede e Security Groups.
- EC2 privada sem exposição direta à internet.
- RDS privado, sem IP público.
- O ambiente atual usa ALB público em HTTP/80 para validação do MVP.
- HTTPS, domínio próprio e camada de borda devem ser tratados como evolução antes de uma publicação produtiva.
- Credenciais fora do código-fonte e fora do GitHub.
- Logs e métricas planejados com CloudWatch.

## Camada de Borda Futura

A camada de borda abaixo não faz parte da implantação atual. Ela permanece planejada como evolução:

- Amazon CloudFront para distribuição e entrada HTTPS.
- AWS WAF para proteção contra ataques web comuns.
- AWS Shield Standard para proteção básica contra DDoS.
- AWS Certificate Manager para certificados TLS.

Essa camada deve ser implantada antes de uma publicação produtiva com domínio próprio e HTTPS.

## Application Load Balancer

O ALB é o ponto de entrada público atual da aplicação dentro da VPC. Ele fica nas subnets públicas e recebe tráfego HTTP/80 da internet.

Regra esperada:

```text
Internet -> HTTP 80 -> SG-ALB
```

O ALB encaminha tráfego apenas para a EC2 privada na porta 80.

## EC2 Privada

A EC2 da aplicação fica em subnet privada e não deve receber tráfego direto da internet. Ela executa os containers Docker do frontend e do backend.

Regra esperada:

```text
SG-ALB -> TCP 80 -> SG-EC2-APP
```

SSH deve permanecer bloqueado. O acesso administrativo à EC2 privada deve ser feito por AWS Systems Manager Session Manager.

## RDS Privado

O Amazon RDS for MariaDB deve ficar em subnets privadas de banco, com `Public accessibility` desativado.

Regra esperada:

```text
SG-EC2-APP -> TCP 3306 -> SG-RDS
```

Não deve existir regra permitindo acesso à porta `3306` a partir de `0.0.0.0/0`.

## Security Groups

| Security Group | Entrada permitida | Saída permitida | Observação |
| --- | --- | --- | --- |
| `SG-ALB` | HTTP `80` da internet | HTTP `80` para `SG-EC2-APP` | Ponto de entrada atual da aplicação |
| `SG-EC2-APP` | HTTP `80` somente do `SG-ALB` | `3306` para `SG-RDS`; `443` via NAT Gateway para atualizações e downloads | EC2 privada com containers |
| `SG-RDS` | `3306` somente do `SG-EC2-APP` | Tráfego de resposta stateful | Banco privado, sem acesso público |

Regras amplas ou não utilizadas devem ser removidas.

O `SG-RDS` nunca deve liberar `3306` para `0.0.0.0/0`.

## IAM e Credenciais

A EC2 deve usar IAM Role. Não devem existir access keys fixas na instância, no `.env`, no repositório, nos Dockerfiles ou nas imagens Docker.

O arquivo `.env` é permitido apenas localmente e não deve ser versionado.

## Secrets Manager

Secrets Manager é uma evolução recomendada para senhas e segredos. No ambiente atual, a senha do RDS deve existir apenas no `dev.tfvars` local e no `.env` gerado internamente na EC2 pelo `user_data`.

## CORS

No ambiente AWS atual, o frontend e a API usam o mesmo domínio do ALB por meio do proxy `/api`, reduzindo dependência de CORS no navegador. Em produção, CORS deve ser restrito ao domínio oficial da aplicação.

## NAT Gateway

O NAT Gateway permite saída controlada da EC2 privada para atualizações e downloads. Ele não deve ser confundido com entrada pública para a aplicação.

No MVP, um NAT Gateway pode reduzir custo e complexidade. Para alta disponibilidade, recomenda-se NAT Gateway por zona de disponibilidade.

## CloudWatch

CloudWatch deve ser usado para logs, métricas e alarmes da aplicação, EC2, ALB e RDS. Métricas e logs de WAF entram apenas quando essa camada futura for implementada.

## Checklist de Riscos

- RDS público.
- Porta `3306` aberta para internet.
- EC2 recebendo tráfego direto da internet.
- SSH aberto para `0.0.0.0/0`.
- Ausência de ALB para entrada controlada.
- CORS aberto em produção.
- `.env` versionado.
- Credenciais reais no GitHub.
- Ausência de backup do RDS.
- Ausência de logs e métricas.
- Falta de HTTPS antes de uma publicação produtiva.
- IAM Role com permissões administrativas amplas.
