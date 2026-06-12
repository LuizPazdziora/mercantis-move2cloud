# Diagramas AWS do MVP

Os diagramas abaixo refletem o ambiente AWS de desenvolvimento do Mercantis Move2Cloud. O fluxo atual usa Application Load Balancer público em HTTP/80, EC2 privada com Docker Compose e Amazon RDS for MariaDB privado. CloudFront, WAF, ACM, Route 53, Auto Scaling e RDS Multi-AZ permanecem como evolução futura.

## Diagrama 1 - Arquitetura AWS Atual

```mermaid
flowchart LR
    usuarios["Usuários"]
    cloudwatch["Amazon CloudWatch\nlogs e métricas"]
    futureEdge["Evolução futura\nCloudFront / WAF / ACM / Route 53"]

    subgraph aws["AWS Cloud"]
        subgraph region["Região sa-east-1 - São Paulo"]
            igw["Internet Gateway"]

            subgraph vpc["VPC 10.0.0.0/16"]
                subgraph publicA["Subnet Pública 1A - 10.0.1.0/24"]
                    alb["Application Load Balancer\nHTTP/80"]
                    nat["NAT Gateway"]
                end

                subgraph publicB["Subnet Pública 1B - 10.0.2.0/24"]
                    albB["ALB distribuído\nsegunda subnet pública"]
                end

                subgraph appA["Subnet Privada de Aplicação 1A - 10.0.11.0/24"]
                    ec2["EC2 privada com Docker Compose"]
                    frontend["frontend-container\nNginx"]
                    backend["backend-api-container\nFastAPI"]
                end

                subgraph appB["Subnet Privada de Aplicação 1B - 10.0.12.0/24"]
                    appExpansion["Reservada para expansão futura"]
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

    usuarios -->|"HTTP 80"| alb
    alb -->|"HTTP 80"| ec2
    ec2 --> frontend
    frontend -->|"proxy /api"| backend
    backend -->|"TCP 3306 privado"| rds
    ec2 -->|"saída controlada"| nat
    nat --> igw
    alb --> cloudwatch
    ec2 --> cloudwatch
    rds --> cloudwatch
    futureEdge -. "não implementado nesta etapa" .-> alb
```

## Diagrama 2 - Fluxo Principal

```mermaid
sequenceDiagram
    participant U as Usuário
    participant ALB as Application Load Balancer
    participant FE as Nginx frontend na EC2
    participant BE as Backend FastAPI
    participant DB as RDS MariaDB privado

    U->>ALB: HTTP 80
    ALB->>FE: Encaminha para porta 80 da EC2
    FE->>FE: Serve frontend em /
    FE->>BE: Proxy /api, /docs e /openapi.json
    BE->>DB: Consulta privada TCP 3306
    DB-->>BE: Dados persistidos
    BE-->>FE: Resposta JSON
    FE-->>U: Interface e dados do MVP
```

## Diagrama 3 - Security Groups

```mermaid
flowchart TB
    internet["Internet"]
    admin["Acesso administrativo via SSM"]

    subgraph sgAlb["SG-ALB"]
        albRule["Entrada HTTP 80"]
        alb["Application Load Balancer"]
    end

    subgraph sgApp["SG-EC2-APP"]
        appRule["Entrada 80\nsomente de SG-ALB"]
        sshRule["SSH bloqueado"]
        ec2["EC2 privada com containers"]
    end

    subgraph sgRds["SG-RDS"]
        dbRule["Entrada 3306\nsomente de SG-EC2-APP"]
        rds["RDS MariaDB sem acesso público"]
    end

    internet -->|"80"| albRule --> alb
    alb -->|"80"| appRule --> ec2
    admin -. "Session Manager" .-> ec2
    sshRule -. "sem entrada pública" .-> ec2
    ec2 -->|"3306"| dbRule --> rds
```
