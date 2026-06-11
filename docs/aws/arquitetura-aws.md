# Arquitetura AWS de Referencia

Este documento descreve a arquitetura AWS de referencia para o Mercantis Move2Cloud. A arquitetura e documental nesta etapa: nenhum recurso real foi criado na AWS, nenhum ambiente foi publicado e nenhuma credencial real deve ser usada.

## Visao geral

O MVP local ja valida o fluxo `Frontend -> Backend FastAPI -> MariaDB` com Docker Compose. A arquitetura AWS de referencia mantem o frontend e o backend como containers Docker, substitui o MariaDB local por Amazon RDS for MariaDB e adiciona isolamento de rede com VPC, subnets, Security Groups, IAM Role e observabilidade.

## Objetivo da arquitetura

- Preparar uma implantacao simples, segura e controlada para validacao em AWS.
- Manter a estrategia de replatform com refactor parcial.
- Reduzir dependencia de componentes locais sem reescrever a aplicacao.
- Separar camadas publica, aplicacao e banco de dados.
- Evitar exposicao direta do banco de dados a internet.
- Definir base para evolucoes futuras como HTTPS, balanceamento, automacao e CI/CD.

## Relacao entre MVP local e AWS

| Camada | Ambiente local | Referencia AWS |
| --- | --- | --- |
| Frontend | Container servido por Nginx em `localhost:8080` | Container Docker em EC2 |
| Backend | FastAPI em container em `localhost:8000` | Container Docker em EC2 |
| Banco | MariaDB em container Docker | Amazon RDS for MariaDB em subnet privada |
| Rede | Rede interna do Docker Compose | Amazon VPC com subnets publicas e privadas |
| Configuracao | `.env` local nao versionado | Variaveis de ambiente e evolucao para Secrets Manager |
| Observabilidade | Logs locais dos containers | CloudWatch Logs e Metrics |

## Fluxo textual

```text
Usuario
-> Internet
-> EC2 publica
-> Containers Docker
-> Backend FastAPI
-> RDS MariaDB privado
```

O usuario acessa a aplicacao pela camada publica. A EC2 hospeda os containers do frontend e do backend. O backend se conecta ao RDS MariaDB por rede privada, usando a porta `3306` permitida apenas entre os Security Groups da aplicacao e do banco.

## Componentes

### Amazon VPC

A VPC isola a rede do projeto dentro da AWS. Ela deve conter subnets publicas para entrada controlada da aplicacao e subnets privadas para recursos que nao devem receber trafego direto da internet.

### Subnet publica

A subnet publica possui rota para o Internet Gateway. No MVP de referencia, a EC2 pode ficar nessa subnet para simplificar a validacao, desde que os Security Groups sejam restritivos.

### Subnet privada

A subnet privada nao possui rota direta de entrada pela internet. O RDS MariaDB deve ficar em subnets privadas, preferencialmente em pelo menos duas zonas de disponibilidade para atender ao requisito de subnet group do RDS e permitir evolucao para Multi-AZ.

### Internet Gateway

O Internet Gateway permite que recursos em subnets publicas tenham comunicacao com a internet conforme as rotas e regras de seguranca definidas.

### Route Table publica

A tabela publica deve conter rota `0.0.0.0/0` para o Internet Gateway. Essa rota deve ser associada apenas as subnets publicas.

### Route Table privada

A tabela privada nao deve expor recursos diretamente a internet. Para esta etapa documental, nao e necessario definir NAT Gateway. Caso a aplicacao precise de saida controlada a internet a partir de subnets privadas em fases futuras, essa decisao deve ser avaliada em conjunto com custo e seguranca.

### Amazon EC2

A EC2 atua como host Docker do MVP na AWS. Ela executa os containers do frontend e do backend. A escolha reduz complexidade inicial e permite validar a arquitetura antes de adotar servicos gerenciados de orquestracao.

### Docker

Docker mantem a mesma estrategia de empacotamento usada localmente. Na AWS, o container `database` nao deve compor a arquitetura final; o banco deve ser substituido por Amazon RDS for MariaDB.

### Frontend containerizado

O frontend permanece como container servido por Nginx. Em uma exposicao publica futura, o trafego deve usar HTTPS e dominio controlado.

### Backend FastAPI containerizado

O backend permanece como container FastAPI. Ele deve receber variaveis de ambiente para conexao com o RDS, incluindo `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` e `DB_PASSWORD`.

### Amazon RDS for MariaDB

O RDS substitui o MariaDB local. Deve ser criado em subnet privada, sem public accessibility, com backup automatico habilitado e Security Group permitindo `3306` apenas a partir do Security Group da EC2.

### Security Groups

Security Groups devem segmentar as camadas:

- `SG-EC2`: permite entrada HTTP/HTTPS conforme fase de publicacao e SSH restrito por IP apenas se necessario.
- `SG-RDS`: permite entrada `3306` somente a partir de `SG-EC2`.

### IAM Role

A EC2 deve usar IAM Role para acessar recursos AWS autorizados, evitando access keys fixas na instancia ou no repositorio.

### CloudWatch

CloudWatch deve receber logs e metricas da aplicacao, da EC2 e do RDS. Alarmes devem ser definidos para indisponibilidade, consumo elevado de CPU, armazenamento baixo e erros recorrentes.

### Secrets Manager como evolucao

Secrets Manager e recomendado para evoluir o tratamento de segredos. Senhas de banco e outros valores sensiveis nao devem ser versionados nem gravados em imagens Docker.

## Justificativa por EC2 + Docker no MVP

EC2 + Docker e uma escolha adequada para o MVP porque preserva o empacotamento local, reduz mudancas na aplicacao, facilita a validacao inicial e evita a complexidade operacional de orquestradores nesta etapa. A decisao e compativel com replatform com refactor parcial: a infraestrutura muda, mas a aplicacao nao e reescrita.

## Limitacoes

- Nao representa alta disponibilidade completa.
- Nao inclui balanceador de carga no desenho inicial.
- Nao inclui escalabilidade automatica.
- Exige gestao operacional da EC2, Docker, atualizacoes e hardening do host.
- Depende de disciplina para configurar variaveis de ambiente e segredos corretamente.
- Nao deve ser publicada sem validacao de seguranca, HTTPS e revisao de acesso.

## Evolucoes futuras possiveis

- Application Load Balancer para entrada HTTP/HTTPS gerenciada.
- ACM para certificados TLS.
- Route 53 para DNS.
- ECS/Fargate para reduzir gestao de servidores.
- Auto Scaling para resiliencia e elasticidade.
- CI/CD para build, teste e deploy controlado.
- Secrets Manager para segredos de producao.
- SSM Session Manager para acesso administrativo sem SSH publico.
