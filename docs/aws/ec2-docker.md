# EC2 com Docker

Este documento descreve o papel da Amazon EC2 como host Docker na arquitetura AWS de referencia do Mercantis Move2Cloud.

## Papel da EC2 no MVP

A EC2 executa os containers da aplicacao em uma instancia controlada. Essa abordagem preserva a organizacao local em containers e reduz a quantidade de mudancas necessarias para uma primeira validacao em AWS.

## Containers esperados

Na AWS, a EC2 deve executar:

- `frontend`: interface web servida por Nginx.
- `backend`: API FastAPI.

O container `database` nao deve ser usado na arquitetura AWS final, pois o banco local em Docker deve ser substituido por Amazon RDS for MariaDB.

## Variaveis de ambiente para RDS

O backend deve receber as variaveis necessarias para conectar ao RDS:

```text
DB_HOST=<endpoint-privado-do-rds>
DB_PORT=3306
DB_NAME=<nome-do-banco>
DB_USER=<usuario-da-aplicacao>
DB_PASSWORD=<senha-gerenciada-fora-do-git>
```

Esses valores nao devem ser versionados. Em evolucao, `DB_PASSWORD` deve ser recuperada por mecanismo seguro, como AWS Secrets Manager.

## IAM Role

A instancia EC2 deve usar IAM Role. Isso evita access keys fixas na instancia e permite conceder permissoes minimas para CloudWatch Logs, SSM Session Manager e leitura de segredos especificos em fases futuras.

## Portas

| Porta | Uso | Observacao |
| --- | --- | --- |
| `80` | HTTP publico | Apenas se liberado formalmente |
| `443` | HTTPS publico | Obrigatorio antes de publicacao real |
| `8080` | Frontend local | Referencia de desenvolvimento |
| `8000` | Backend local | Referencia de desenvolvimento |
| `3306` | MariaDB | Somente EC2 -> RDS via Security Group |
| `22` | SSH | Usar apenas se necessario e restrito por IP |

## Execucao Docker conceitual

Os comandos abaixo sao conceituais e devem ser adaptados ao processo de deploy aprovado. Eles nao contem credenciais reais.

```bash
docker build -t mercantis-frontend ./frontend
docker build -t mercantis-backend ./backend

docker network create mercantis-network

docker run -d --name mercantis-backend \
  --network mercantis-network \
  -e DB_HOST="<endpoint-privado-do-rds>" \
  -e DB_PORT="3306" \
  -e DB_NAME="<nome-do-banco>" \
  -e DB_USER="<usuario-da-aplicacao>" \
  -e DB_PASSWORD="<senha-fora-do-repositorio>" \
  mercantis-backend

docker run -d --name mercantis-frontend \
  --network mercantis-network \
  -p 80:80 \
  mercantis-frontend
```

## Cuidados operacionais

- Nao gravar credenciais em Dockerfile, imagem ou repositorio.
- Nao usar `.env` com valores reais versionados.
- Aplicar atualizacoes de seguranca no sistema operacional da EC2.
- Enviar logs para CloudWatch em evolucao operacional.
- Documentar a versao da imagem usada para permitir rollback.
