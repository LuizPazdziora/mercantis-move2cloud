# Diagramas AWS de Referência

Os diagramas abaixo estão em Mermaid e refletem o diagrama visual "Mercantis Move2Cloud - Infraestrutura AWS do MVP". Eles são referência documental e não indicam que recursos reais foram criados.

## Diagrama 1 — Arquitetura AWS do MVP

```mermaid
flowchart LR
    usuarios["Usuários"]
    cloudfront["Amazon CloudFront"]
    waf["AWS WAF"]
    shield["AWS Shield Standard"]
    acm["AWS Certificate Manager"]
    cloudwatch["Amazon CloudWatch\nlogs e métricas"]
    secrets["AWS Secrets Manager\nevolução para segredos"]
    s3["Amazon S3\nopcional/evolução"]

    subgraph aws["AWS Cloud"]
        subgraph region["Região sa-east-1 - São Paulo"]
            igw["Internet Gateway"]

            subgraph vpc["VPC 10.0.0.0/16"]
                subgraph publicA["Subnet Pública 1A - 10.0.1.0/24"]
                    alb["Application Load Balancer"]
                    nat["NAT Gateway"]
                end

                subgraph publicB["Subnet Pública 1B - 10.0.2.0/24"]
                    albB["ALB distribuído\nsegunda subnet pública"]
                end

                subgraph appA["Subnet Privada de Aplicação 1A - 10.0.11.0/24"]
                    ec2["EC2 privada com Docker"]
                    frontend["frontend-container\nNginx/web"]
                    backend["backend-api-container\nFastAPI"]
                end

                subgraph appB["Subnet Privada de Aplicação 1B - 10.0.12.0/24"]
                    appExpansion["Reservada para expansão futura\nalta disponibilidade"]
                end

                subgraph dbA["Subnet Privada de Banco 1A - 10.0.21.0/24"]
                    rds["Amazon RDS for MariaDB"]
                end

                subgraph dbB["Subnet Privada de Banco 1B - 10.0.22.0/24"]
                    dbExpansion["DB Subnet Group\ne evolução Multi-AZ"]
                end
            end
        end
    end

    usuarios -->|"HTTPS 443"| cloudfront
    cloudfront --> waf
    waf --> shield
    acm -. "certificado TLS" .-> cloudfront
    shield -->|"HTTPS 443"| alb
    alb -->|"HTTP 80/8080 interno"| ec2
    ec2 --> frontend
    frontend --> backend
    backend -->|"TCP 3306 privado"| rds
    ec2 -->|"saída controlada"| nat
    nat --> igw
    alb --> cloudwatch
    ec2 --> cloudwatch
    rds --> cloudwatch
    backend -. "leitura futura de segredo" .-> secrets
    backend -. "artefatos ou arquivos futuros" .-> s3
```

## Diagrama 2 — Fluxo Principal

```mermaid
sequenceDiagram
    participant U as Usuário
    participant CF as CloudFront/WAF
    participant ALB as Application Load Balancer
    participant EC2 as EC2 privada com Docker
    participant FE as frontend-container
    participant BE as backend-api-container
    participant DB as RDS MariaDB privado

    U->>CF: HTTPS 443
    CF->>ALB: Requisição autorizada
    ALB->>EC2: Encaminha para porta interna
    EC2->>FE: Entrega interface web
    FE->>BE: Chamada para API
    BE->>DB: Consulta privada TCP 3306
    DB-->>BE: Dados persistidos
    BE-->>FE: Resposta JSON
    FE-->>U: Atualização da interface
```

## Diagrama 3 — Security Groups

```mermaid
flowchart TB
    edge["CloudFront / Internet"]
    admin["Acesso administrativo aprovado"]

    subgraph sgAlb["SG-ALB"]
        albRule["Entrada HTTPS 443"]
        alb["Application Load Balancer"]
    end

    subgraph sgApp["SG-EC2-APP"]
        appRule["Entrada 80/8080\nsomente de SG-ALB"]
        sshRule["SSH bloqueado ou restrito"]
        ec2["EC2 privada com containers"]
    end

    subgraph sgRds["SG-RDS"]
        dbRule["Entrada 3306\nsomente de SG-EC2-APP"]
        rds["RDS MariaDB sem acesso público"]
    end

    edge -->|"443"| albRule --> alb
    alb -->|"80/8080"| appRule --> ec2
    admin -. "SSM Session Manager preferencial" .-> ec2
    admin -. "SSH somente se restrito" .-> sshRule
    ec2 -->|"3306"| dbRule --> rds
```
