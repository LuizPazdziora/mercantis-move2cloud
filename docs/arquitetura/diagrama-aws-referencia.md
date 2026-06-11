# Diagramas AWS de Referencia

Os diagramas abaixo estao em Mermaid e podem ser exportados para PNG ou SVG por ferramentas compativeis. Eles representam a arquitetura AWS de referencia e nao indicam que recursos reais foram criados.

## Arquitetura AWS de referencia

```mermaid
flowchart LR
    usuario["Usuario"]
    internet["Internet"]
    igw["Internet Gateway"]
    cloudwatch["CloudWatch Logs/Metrics"]
    secrets["Secrets Manager (evolucao)"]

    subgraph vpc["Amazon VPC 10.0.0.0/16"]
        subgraph publicSubnet["Public Subnet"]
            ec2["EC2 com Docker"]
            frontend["Container frontend / Nginx"]
            backend["Container backend / FastAPI"]
        end

        subgraph privateSubnet["Private Subnet"]
            rds["Amazon RDS for MariaDB"]
        end
    end

    usuario --> internet
    internet --> igw
    igw --> ec2
    ec2 --> frontend
    frontend --> backend
    backend --> rds
    ec2 --> cloudwatch
    backend -. leitura futura de segredo .-> secrets
```

## Fluxo de comunicacao

```mermaid
sequenceDiagram
    participant U as Usuario
    participant F as Frontend
    participant B as Backend FastAPI
    participant R as RDS MariaDB

    U->>F: Acessa interface web
    F->>B: Requisicoes HTTP para API
    B->>R: Consultas SQL via rede privada
    R-->>B: Dados persistidos
    B-->>F: Respostas JSON
    F-->>U: Atualizacao da interface
```

## Security Groups

```mermaid
flowchart TB
    internet["Internet"]
    admin["IP administrativo autorizado"]

    subgraph sgEc2["SG-EC2"]
        http["Entrada HTTP/HTTPS\n80/443"]
        ssh["Entrada SSH restrita\n22"]
        ec2["EC2 com containers"]
    end

    subgraph sgRds["SG-RDS"]
        mariadb["Entrada MariaDB\n3306 somente de SG-EC2"]
        rds["RDS MariaDB privado"]
    end

    internet --> http --> ec2
    admin --> ssh --> ec2
    ec2 --> mariadb --> rds
```
