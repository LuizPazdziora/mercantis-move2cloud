# Validação AWS

Este documento descreve validações futuras para a arquitetura AWS de referência do Mercantis Move2Cloud. Ele não executa recursos reais e não substitui evidências obtidas em uma implantação aprovada.

## Validação de VPC

- Confirmar VPC `10.0.0.0/16`.
- Confirmar região `sa-east-1`.
- Confirmar separação entre subnets públicas, privadas de aplicação e privadas de banco.

Evidência esperada: registro da VPC, CIDR e subnets associadas.

## Validação de Subnets

- Subnets públicas: `10.0.1.0/24` e `10.0.2.0/24`.
- Subnets privadas de aplicação: `10.0.11.0/24` e `10.0.12.0/24`.
- Subnets privadas de banco: `10.0.21.0/24` e `10.0.22.0/24`.
- Subnets distribuídas em mais de uma zona de disponibilidade.

Evidência esperada: mapa de subnets e zonas.

## Validação de Rotas

- Subnets públicas com rota para Internet Gateway.
- Subnets privadas de aplicação com saída controlada via NAT Gateway, se necessário.
- Subnets privadas de banco sem rota direta para Internet Gateway.

Evidência esperada: route tables associadas às subnets corretas.

## Validação do Internet Gateway

- Internet Gateway associado à VPC.
- Rota pública aplicada somente às subnets públicas.

Evidência esperada: associação do IGW e route table pública.

## Validação do NAT Gateway

- NAT Gateway em subnet pública.
- Subnet privada de aplicação com rota de saída para o NAT Gateway.
- Registro de que, no MVP, um NAT Gateway pode ser usado por custo e simplicidade.

Evidência esperada: rota privada e NAT Gateway ativo.

## Validação dos Security Groups

- `SG-ALB` recebe HTTPS `443`.
- `SG-EC2-APP` recebe `80` ou `8080` somente do `SG-ALB`.
- `SG-RDS` recebe `3306` somente do `SG-EC2-APP`.
- SSH bloqueado ou restrito.
- Porta `3306` não aberta para `0.0.0.0/0`.

Evidência esperada: regras de entrada e saída por Security Group.

## Validação do ALB

- ALB posicionado nas subnets públicas.
- Listener HTTPS planejado.
- Target group apontando para EC2 privada.
- Health check configurado para endpoint adequado.

Evidência esperada: target healthy e resposta HTTP esperada.

## Validação da EC2 Privada

- EC2 em subnet privada de aplicação.
- Sem IP público.
- Sem entrada direta da internet.
- Docker instalado e containers ativos.
- IAM Role associada.

Evidência esperada: detalhes da instância, rede, role e containers.

## Validação EC2 -> RDS

- Backend conecta ao endpoint privado do RDS.
- Porta usada: `3306`.
- `/db-health` responde com sucesso.

Evidência esperada: resposta do endpoint e logs do backend.

## Validação do RDS

- RDS em subnets privadas de banco.
- `Public accessibility` desativado.
- Backup automático habilitado ou planejado.
- DB Subnet Group com subnets em mais de uma zona.

Evidência esperada: configuração do RDS sem dados sensíveis.

## Validação de CloudFront, WAF e ACM

Se implantados:

- CloudFront distribuindo tráfego HTTPS.
- WAF associado e com regras básicas.
- Certificado ACM válido.
- Shield Standard considerado na proteção de borda.

Evidência esperada: distribuição, certificado e regras WAF.

## Validação de CORS

- CORS restrito ao domínio correto.
- CORS aberto não utilizado em ambiente publicado.

Evidência esperada: headers de resposta da API.

## Validação de CloudWatch

- Logs do backend, frontend, EC2, ALB, WAF e RDS planejados ou ativos.
- Métricas de EC2 e RDS acompanhadas.
- Alarmes básicos definidos ou documentados.

Evidência esperada: grupos de logs, métricas e alarmes.

## Validação de Backup

- Backup automático do RDS habilitado ou formalmente planejado.
- Snapshot manual antes de mudanças críticas.
- Plano de rollback documentado.

Evidência esperada: política de backup e registro de snapshot, quando aplicável.
