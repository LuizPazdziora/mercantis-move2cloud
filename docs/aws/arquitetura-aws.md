# Arquitetura AWS de Referência

Este documento descreve a arquitetura AWS de referência do Mercantis Move2Cloud alinhada ao diagrama "Mercantis Move2Cloud - Infraestrutura AWS do MVP". A arquitetura é documental nesta etapa: nenhum recurso real foi criado na AWS, nenhum ambiente foi publicado e nenhuma credencial real deve ser usada.

## Visão Geral

O MVP local continua funcionando com Docker Compose no fluxo `Frontend -> Backend FastAPI -> MariaDB`. A arquitetura AWS de referência mantém a aplicação containerizada, mas substitui o banco local por Amazon RDS for MariaDB e coloca a execução dos containers em uma EC2 privada atrás de uma camada pública controlada.

Fluxo principal documentado:

```text
Usuários
-> HTTPS 443
-> Amazon CloudFront / AWS WAF / AWS Shield Standard / ACM
-> Application Load Balancer em subnets públicas
-> EC2 privada com Docker
-> frontend-container e backend-api-container
-> Amazon RDS for MariaDB em subnet privada de banco
```

## Objetivos

- Manter a estratégia de replatform com refactor parcial.
- Usar EC2 privada como host Docker para frontend e backend.
- Usar Amazon RDS for MariaDB como banco gerenciado privado.
- Evitar exposição direta da EC2 e do RDS à internet.
- Definir uma camada de borda com CloudFront, WAF, Shield Standard e ACM.
- Preparar expansão futura para alta disponibilidade em múltiplas zonas.
- Documentar controles de segurança, observabilidade, backup e rollback.

## Relação Entre Ambiente Local e AWS

| Camada | Ambiente local | Referência AWS |
| --- | --- | --- |
| Entrada | Navegador em `localhost` | CloudFront, WAF, Shield Standard, ACM e ALB |
| Frontend | Container Nginx em `localhost:8080` | `frontend-container` em EC2 privada |
| Backend | FastAPI em `localhost:8000` | `backend-api-container` em EC2 privada |
| Banco | MariaDB em container Docker | Amazon RDS for MariaDB em subnet privada de banco |
| Rede | Rede interna do Docker Compose | VPC `10.0.0.0/16` com subnets públicas e privadas |
| Saída da aplicação | Host local | NAT Gateway para saída controlada da EC2 privada |
| Segredos | `.env` local não versionado | Evolução para AWS Secrets Manager |
| Logs e métricas | Logs locais dos containers | Amazon CloudWatch |

## Componentes da Arquitetura

### Camada de Borda

CloudFront, AWS WAF, AWS Shield Standard e AWS Certificate Manager formam a camada de borda planejada para publicação controlada.

- **CloudFront:** distribui o tráfego HTTPS e permite evolução para CDN.
- **AWS WAF:** protege contra padrões comuns de ataques web.
- **AWS Shield Standard:** fornece proteção básica contra DDoS sem configuração adicional.
- **ACM:** gerencia certificados TLS para HTTPS.

Essa camada deve ser usada antes de qualquer exposição pública real.

### Application Load Balancer

O ALB é o ponto de entrada público da camada de aplicação. Ele fica nas subnets públicas e recebe tráfego HTTPS 443 da camada de borda. Em seguida, encaminha o tráfego para a EC2 privada pela porta interna definida para os containers, como `80` ou `8080`.

A EC2 não recebe tráfego direto da internet.

### VPC

A VPC `10.0.0.0/16` isola os recursos do projeto. Ela separa subnets públicas, subnets privadas de aplicação e subnets privadas de banco.

### Subnets Públicas

As subnets públicas hospedam componentes que precisam de rota pública controlada:

- Application Load Balancer.
- NAT Gateway.
- Integração com Internet Gateway.

CIDRs sugeridos:

- `10.0.1.0/24`
- `10.0.2.0/24`

### Subnets Privadas de Aplicação

As subnets privadas de aplicação hospedam a EC2 com Docker. A primeira zona pode executar o MVP, enquanto a segunda fica reservada para expansão futura.

CIDRs sugeridos:

- `10.0.11.0/24`
- `10.0.12.0/24`

### Subnets Privadas de Banco

As subnets privadas de banco hospedam o Amazon RDS for MariaDB por meio de um DB Subnet Group.

CIDRs sugeridos:

- `10.0.21.0/24`
- `10.0.22.0/24`

O RDS não deve ter IP público.

### Internet Gateway

O Internet Gateway atende a camada pública da VPC. Ele deve ser associado apenas às rotas das subnets públicas.

### NAT Gateway

O NAT Gateway permite que a EC2 privada faça saída controlada para atualizações, downloads e integrações necessárias, sem receber conexões diretas da internet.

No MVP, um NAT Gateway pode ser suficiente para reduzir custo e complexidade. Em produção com alta disponibilidade, a recomendação é usar um NAT Gateway por zona de disponibilidade.

### EC2 Privada com Docker

A EC2 fica em subnet privada de aplicação e executa os containers:

- `frontend-container`
- `backend-api-container`

O container `database` não deve fazer parte da arquitetura AWS final. O banco deve ser Amazon RDS for MariaDB.

### Amazon RDS for MariaDB

O RDS fica em subnet privada de banco, com `Public accessibility` desativado. A porta `3306` deve ser permitida somente a partir do Security Group da aplicação.

### Security Groups

Os Security Groups segmentam a comunicação entre camadas:

- `SG-ALB`: recebe HTTPS 443 da camada de borda.
- `SG-EC2-APP`: recebe `80` ou `8080` somente do `SG-ALB`.
- `SG-RDS`: recebe `3306` somente do `SG-EC2-APP`.

SSH deve permanecer bloqueado ou fortemente restrito. A evolução recomendada para acesso administrativo é AWS Systems Manager Session Manager.

### IAM Role

A EC2 deve usar IAM Role. Não devem existir access keys fixas dentro da instância, no repositório ou em imagens Docker.

### CloudWatch

CloudWatch é o serviço recomendado para logs, métricas e alarmes da EC2, containers, ALB, RDS e WAF.

### Secrets Manager

Secrets Manager é uma evolução recomendada para segredos, como senha do banco. Ele não é obrigatório para a versão local e não deve ser confundido com `.env` de desenvolvimento.

### Amazon S3

S3 é um componente auxiliar e opcional para evolução futura, podendo ser usado para artefatos, arquivos estáticos ou backups exportados. Ele não é dependência obrigatória do MVP.

## Justificativas Técnicas

### EC2 privada atrás de ALB

Essa escolha reduz exposição direta da aplicação e mantém a simplicidade operacional do MVP. O ALB concentra a entrada pública, enquanto a EC2 recebe tráfego apenas da camada autorizada.

### RDS privado

O banco não deve ser acessível pela internet. O RDS privado reduz superfície de ataque e mantém o backend como única camada autorizada a consultar dados.

### Camada de borda

CloudFront, WAF, Shield Standard e ACM criam uma base para publicação HTTPS controlada, proteção contra ataques comuns e gestão de certificado.

## Limitações do MVP

- A segunda zona de disponibilidade é documentada como expansão futura.
- O desenho não promete alta disponibilidade completa na primeira implantação.
- Um único NAT Gateway reduz custo, mas não oferece resiliência por zona.
- ECS/Fargate e Kubernetes não fazem parte da etapa atual.
- A publicação pública depende de aprovação, HTTPS, CORS revisado, logs, backup e checklist de segurança.

## Evoluções Futuras

- Ativar múltiplas instâncias EC2 em subnets privadas diferentes.
- Usar Auto Scaling Group atrás do ALB.
- Migrar para ECS/Fargate se a operação justificar.
- Habilitar Multi-AZ no RDS.
- Usar Secrets Manager para segredos com rotação planejada.
- Consolidar dashboards e alarmes no CloudWatch.
- Exportar artefatos e evidências para S3, se necessário.
