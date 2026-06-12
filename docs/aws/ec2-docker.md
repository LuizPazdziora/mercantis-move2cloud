# EC2 com Docker

Este documento descreve a Amazon EC2 como host Docker privado no ambiente AWS de desenvolvimento do Mercantis Move2Cloud.

## Papel da EC2 no MVP

A EC2 executa os containers da aplicação em uma subnet privada de aplicação. Ela não possui exposição pública direta e não recebe tráfego direto da internet. O acesso externo atual chega pelo Application Load Balancer público.

Essa abordagem mantém a simplicidade do Docker usado localmente e melhora o isolamento de rede da aplicação.

## Posicionamento de Rede

- Subnet privada de aplicação: `10.0.11.0/24` no MVP.
- Subnet privada de aplicação secundária: `10.0.12.0/24` para expansão futura.
- Entrada permitida apenas a partir do Security Group do ALB.
- Saída para internet, quando necessária, via NAT Gateway.
- Nenhuma porta da EC2 deve ser aberta diretamente para a internet.

## Containers Esperados

Na AWS, a EC2 deve executar:

- `frontend-container`: interface web servida por Nginx.
- `backend-api-container`: API FastAPI.

O container `database` não é usado na arquitetura AWS. O banco local em Docker é substituído por Amazon RDS for MariaDB.

## Variáveis de Ambiente Para RDS

O backend deve receber as variáveis necessárias para conectar ao RDS:

```text
DB_HOST=<endpoint-privado-do-rds>
DB_PORT=3306
DB_NAME=<nome-do-banco>
DB_USER=<usuario-do-banco>
DB_PASSWORD=<segredo-gerenciado-fora-do-git>
```

Esses valores não devem ser versionados. No ambiente atual, o `.env` da EC2 é gerado pelo `user_data` a partir de variáveis sensíveis do Terraform. Em evolução, `DB_PASSWORD` deve ser recuperada de forma segura, por exemplo pelo AWS Secrets Manager.

## Entrada Pelo ALB

O ALB fica em subnets públicas e encaminha tráfego para a EC2 privada. No ambiente atual, a porta `80` representa o tráfego interno recebido do ALB, não tráfego direto da internet.

Regras recomendadas:

- `SG-ALB` recebe HTTP `80` da internet.
- `SG-EC2-APP` recebe `80` somente do `SG-ALB`.
- A EC2 não expõe portas diretamente para `0.0.0.0/0`.

## Saída Via NAT Gateway

A EC2 privada pode precisar acessar a internet para atualizações ou downloads. Essa saída deve ocorrer por NAT Gateway. No MVP, um NAT Gateway pode reduzir custo e complexidade; em alta disponibilidade, recomenda-se NAT Gateway por zona.

## Acesso Administrativo

SSH deve permanecer bloqueado. O acesso administrativo deve ocorrer por AWS Systems Manager Session Manager, com IAM Role apropriada e trilha de auditoria.

## IAM Role

A instância EC2 deve usar IAM Role. Não devem ser usadas access keys dentro da instância, no `.env`, no repositório ou em imagens Docker.

Permissões atuais e futuras possíveis:

- acesso administrativo via SSM Session Manager;
- envio de logs para CloudWatch Logs;
- leitura futura de segredos específicos no Secrets Manager.

## Execução Docker

Na EC2, a aplicação é iniciada pelo `user_data` com:

```bash
docker compose -f docker-compose.aws.yml up -d --build
```

Os comandos abaixo são referência operacional simplificada. Eles não devem conter credenciais reais.

```bash
docker build -t mercantis-frontend ./frontend
docker build -t mercantis-backend ./backend

docker network create mercantis-network

docker run -d --name backend-api-container \
  --network mercantis-network \
  -e DB_HOST="<endpoint-privado-do-rds>" \
  -e DB_PORT="3306" \
  -e DB_NAME="<nome-do-banco>" \
  -e DB_USER="<usuario-do-banco>" \
  -e DB_PASSWORD="<segredo-fora-do-repositorio>" \
  mercantis-backend

# Porta publicada apenas no host privado; origem permitida somente pelo SG-ALB.
docker run -d --name frontend-container \
  --network mercantis-network \
  -p 80:80 \
  mercantis-frontend
```

## Cuidados Operacionais

- Não gravar credenciais em Dockerfile, imagem ou repositório.
- Não versionar `.env`.
- Não usar banco em container na AWS.
- Atualizar sistema operacional e Docker da EC2.
- Enviar logs para CloudWatch em evolução operacional.
- Versionar imagens para permitir rollback.
