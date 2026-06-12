# Validação AWS

Este documento descreve a validação esperada para o ambiente AWS de desenvolvimento do Mercantis Move2Cloud, provisionado com Terraform.

## Arquitetura Validada

```text
Usuário
-> Application Load Balancer público HTTP/80
-> EC2 privada executando Docker Compose
-> Frontend Nginx
-> Backend FastAPI via proxy /api
-> Amazon RDS for MariaDB privado
```

O ambiente local continua disponível com `docker-compose.yml`, frontend em `localhost:8080`, backend em `localhost:8000` e MariaDB local publicado em `127.0.0.1:3307`. Na AWS, o banco não roda em container; o backend usa o endpoint privado do RDS.

## Validação do ALB

- Application Load Balancer em subnets públicas.
- Listener HTTP `80`.
- Target Group associado à EC2 privada.
- Target Group em estado `healthy`.
- Health check em `/`.

Evidências esperadas:

```bash
curl http://<alb_dns_name>/
```

Resultado esperado: HTML do frontend.

## Validação do Frontend

- Frontend servido por Nginx na EC2.
- Swagger acessível por `/docs` no mesmo domínio do ALB.
- O frontend consome o backend por caminhos relativos em `/api`, sem depender de `localhost`.

Evidências esperadas:

```bash
curl -I http://<alb_dns_name>/
curl -I http://<alb_dns_name>/docs
```

## Validação do Backend

- Backend FastAPI executando em container Docker.
- Backend acessível apenas pela rede Docker interna e pelo proxy Nginx.
- Endpoint de saúde respondendo via ALB:

```bash
curl http://<alb_dns_name>/api/health
```

Resultado esperado:

```json
{"status":"ok","service":"mercantis-backend"}
```

## Validação EC2 -> RDS

- EC2 em subnet privada de aplicação.
- RDS em subnets privadas de banco.
- RDS com `Public accessibility` desativado.
- Security Group do RDS permitindo `3306` somente a partir do Security Group da EC2.
- `/api/db-health` validando conexão real com MariaDB.

Evidência esperada:

```bash
curl http://<alb_dns_name>/api/db-health
```

Resultado esperado: resposta com `status: ok` e detalhe de conexão validada.

## Validação dos Dados Iniciais

O `user_data` da EC2 executa `database/init.sql` e `database/seed.sql` contra o RDS. A lista de produtos deve retornar dados iniciais:

```bash
curl http://<alb_dns_name>/api/products
```

Resultado esperado: lista JSON com produtos de demonstração.

## Validação Operacional na EC2

O acesso administrativo à EC2 deve ser feito por AWS Systems Manager Session Manager.

Comandos úteis na sessão SSM:

```bash
sudo cloud-init status --long
sudo tail -n 300 /var/log/cloud-init-output.log
sudo tail -n 300 /var/log/mercantis-user-data.log
sudo docker ps -a
cd /opt/mercantis-move2cloud
sudo docker compose -f docker-compose.aws.yml ps
sudo docker compose -f docker-compose.aws.yml logs --tail=150
```

## Segurança e Segredos

- `dev.tfvars` é local e não deve ser versionado.
- `.env` local não deve ser versionado.
- Senhas reais não devem aparecer em README, documentação, commits ou arquivos de exemplo.
- `db_password` é variável sensível no Terraform.
- Se uma senha for exposta em logs ou conversas, a prática recomendada é rotacioná-la.

## Evolução Futura

Os itens abaixo não fazem parte da implantação atual:

- CloudFront.
- AWS WAF.
- HTTPS com ACM.
- Route 53 e domínio próprio.
- Auto Scaling.
- RDS Multi-AZ.

Esses componentes permanecem como evolução futura e devem ser documentados separadamente quando forem implementados.
