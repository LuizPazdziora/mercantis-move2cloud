# Terraform

Esta pasta contém a infraestrutura como código do Mercantis Move2Cloud para um ambiente AWS de desenvolvimento.

O código prepara uma implantação funcional no fluxo:

```text
Usuário
-> Application Load Balancer público
-> EC2 privada com Docker
-> Amazon RDS for MariaDB privado
```

A camada CloudFront, WAF, Shield e ACM permanece como evolução planejada para uma etapa posterior. Nesta etapa, o acesso público acontece pelo DNS do Application Load Balancer.

## Pré-requisitos

- Terraform `>= 1.6`.
- Credenciais AWS configuradas fora do repositório, por exemplo via AWS CLI, AWS SSO, variáveis de ambiente, AWS CloudShell ou mecanismo corporativo aprovado.
- Permissões AWS para criar VPC, subnets, Internet Gateway, NAT Gateway, Security Groups, RDS, EC2, IAM Role, Instance Profile e Application Load Balancer.
- Repositório GitHub público acessível pela EC2:

```text
https://github.com/LuizPazdziora/mercantis-move2cloud
```

Não coloque access keys, secret keys, tokens, senhas reais ou arquivos `*.tfvars` reais no GitHub.

## Estrutura

```text
infra/terraform/
├── envs/
│   └── dev/
│       ├── main.tf
│       ├── outputs.tf
│       ├── providers.tf
│       ├── variables.tf
│       ├── versions.tf
│       └── dev.tfvars.example
└── modules/
    ├── network/
    ├── security-groups/
    ├── rds/
    ├── ec2-docker/
    ├── alb/
    ├── edge/
    └── observability/
```

O diretório operacional para o ambiente dev é:

```bash
infra/terraform/envs/dev
```

## Ordem dos módulos

1. `network`: cria VPC, subnets públicas, subnets privadas de aplicação, subnets privadas de banco, Internet Gateway, NAT Gateway e rotas.
2. `security-groups`: cria SG-ALB, SG-EC2-APP e SG-RDS com comunicação restrita entre camadas.
3. `rds`: cria DB Subnet Group e Amazon RDS for MariaDB privado.
4. `ec2-docker`: cria IAM Role, Instance Profile e EC2 privada com Docker, clona o repositório e sobe os containers.
5. `alb`: cria Application Load Balancer público, Target Group, Listener HTTP 80 e health check.

Os módulos `edge` e `observability` permanecem reservados para evolução futura.

## Configuração do dev.tfvars

Crie um arquivo local a partir do exemplo:

Windows PowerShell:

```powershell
cd infra\terraform\envs\dev
copy dev.tfvars.example dev.tfvars
```

Linux, macOS ou AWS CloudShell:

```bash
cd infra/terraform/envs/dev
cp dev.tfvars.example dev.tfvars
```

Edite `dev.tfvars` e substitua:

```hcl
db_password = "ALTERE_ESTA_SENHA_FORA_DO_GIT"
```

Use uma senha forte apenas no arquivo local. O arquivo `dev.tfvars` é ignorado pelo Git e não deve ser versionado.

O arquivo `dev.tfvars.example` é apenas referência. Não execute `terraform apply -var-file="dev.tfvars.example"` e não coloque senha real em nenhum arquivo `*.example`, README, prompt, commit ou documentação.

O Terraform possui validação para impedir senha vazia ou valores reservados como `ALTERE_ESTA_SENHA_FORA_DO_GIT`, `CHANGE_ME`, `password` e `senha`. Se essa validação falhar, atualize somente o `dev.tfvars` local, sem commitar o arquivo.

No Windows PowerShell, o arquivo local pode ser preparado com:

```powershell
.\scripts\aws\prepare-dev-tfvars.ps1
```

Esse script apenas copia `dev.tfvars.example` para `dev.tfvars` quando o arquivo local ainda não existe e abre o Notepad para edição. Ele não pede, não salva e não imprime a senha.

Em produção, a recomendação é substituir esse fluxo por AWS Secrets Manager ou SSM Parameter Store. Para este ambiente dev, a senha é passada ao Terraform como variável sensível e usada no `user_data` da EC2 para gerar o `.env` local da instância.

O valor sensível informado localmente em `var.db_password` é usado em dois pontos:

- Configuração do Amazon RDS for MariaDB.
- Geração do `.env` interno da EC2 via `user_data`, com `DB_PASSWORD` renderizado pelo Terraform.

## Comandos

Execute a partir de `infra/terraform/envs/dev`:

```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

O comando `terraform apply` cria recursos reais e pode gerar cobrança na AWS. Execute apenas após revisão e autorização.

Para remover o ambiente criado manualmente:

```bash
terraform destroy -var-file="dev.tfvars"
```

O `destroy` remove recursos e pode apagar dados do RDS. Confirme antes de executar. Para ambientes que precisem preservar dados, revise `db_skip_final_snapshot` e `db_deletion_protection`.

## Recursos criados pelo apply

- VPC `10.0.0.0/16`.
- Duas subnets públicas: `10.0.1.0/24` e `10.0.2.0/24`.
- Duas subnets privadas de aplicação: `10.0.11.0/24` e `10.0.12.0/24`.
- Duas subnets privadas de banco: `10.0.21.0/24` e `10.0.22.0/24`.
- Internet Gateway.
- Elastic IP e NAT Gateway.
- Route Tables e associações.
- Security Groups para ALB, EC2 e RDS.
- Amazon RDS for MariaDB privado, criptografado e sem IP público.
- IAM Role e Instance Profile para EC2.
- EC2 privada com Amazon Linux 2023 e Docker.
- Application Load Balancer público, Target Group e Listener HTTP 80.

## Como a aplicação fica online

O ALB encaminha HTTP 80 para a EC2 privada na porta 80, onde o frontend Nginx está publicado. Na EC2, o `docker-compose.aws.yml` sobe:

- `frontend`: Nginx servindo a interface na porta 80.
- `backend`: FastAPI exposto apenas na rede Docker interna.

O professor acessa o frontend pelo DNS público retornado em `alb_dns_name`. O frontend chama a API usando caminhos relativos em `/api`, como `/api/health`, `/api/db-health`, `/api/products` e `/api/orders`. O Nginx encaminha `/api/*` para `backend:8000` dentro da EC2. O navegador do usuário acessa apenas o DNS público do ALB, sem depender de `localhost`.

O health check do ALB valida o frontend em:

```text
/
```

Esse caminho é servido diretamente pelo Nginx do frontend. A disponibilidade do backend continua validável via proxy em `/api/health` e `/api/db-health`.

## Outputs

Após o `apply`, consulte:

```bash
terraform output
```

Outputs principais:

- `vpc_id`
- `public_subnet_ids`
- `private_app_subnet_ids`
- `private_db_subnet_ids`
- `alb_dns_name`
- `rds_endpoint`
- `ec2_private_ip`

A URL esperada da aplicação será:

```text
http://<alb_dns_name>
```

Exemplo de validação:

```bash
curl http://$(terraform output -raw alb_dns_name)/
curl http://$(terraform output -raw alb_dns_name)/api/health
curl http://$(terraform output -raw alb_dns_name)/api/db-health
curl http://$(terraform output -raw alb_dns_name)/api/products
```

## Diagnóstico de 502 no ALB

Se o Application Load Balancer retornar `502 Bad Gateway` ou o Target Group ficar `unhealthy`, valide primeiro a inicialização da EC2 e dos containers. O fluxo esperado é: o `user_data` instala Docker, clona o repositório, cria o `.env` local da EC2, inicializa o schema no RDS e executa `docker compose -f docker-compose.aws.yml up -d --build`.

Pontos de verificação pela sessão SSM da EC2:

```bash
sudo cloud-init status --long
sudo tail -n 200 /var/log/cloud-init-output.log
sudo tail -n 200 /var/log/mercantis-user-data.log
docker ps
cd /opt/mercantis-move2cloud
docker compose -f docker-compose.aws.yml ps
docker compose -f docker-compose.aws.yml logs --tail=200
curl -i http://localhost/
curl -i http://localhost/api/health
curl -i http://localhost/api/db-health
```

Se o `cloud-init` falhar durante a instalação do Docker, confirme no log que o comando executado é:

```bash
systemctl enable --now docker
```

No Amazon Linux 2023, o sistema pode vir com `curl-minimal` instalado. Instalar o pacote `curl` completo pode gerar conflito com `curl-minimal`, por isso o `user_data` instala apenas `docker` e `git`:

```bash
dnf install -y docker git
```

O script usa o `curl` já disponível no sistema e valida sua presença antes de baixar o plugin do Docker Compose:

```bash
command -v curl
curl --version
```

O `user_data` também registra a versão instalada com:

```bash
docker --version
```

Se o `.env` renderizado na EC2 mostrar `DB_PASSWORD=ALTERE_ESTA_SENHA_FORA_DO_GIT`, o `dev.tfvars` local ainda está com o placeholder e precisa ser corrigido antes de recriar a instância. A senha real deve existir apenas no ambiente local ou em mecanismo seguro equivalente, nunca no Git.

Também confirme no console AWS:

- Target Group associado ao ALB.
- Status do Target Group e motivo do health check.
- Porta do Target Group apontando para `80`.
- Health check em `/`.
- Security Group do ALB permitindo HTTP `80`.
- Security Group da EC2 permitindo entrada apenas do SG do ALB na porta `80`.

Para reaplicar somente o bootstrap da aplicação, sem destruir RDS, VPC, ALB ou demais recursos, recrie apenas a EC2:

```bash
terraform apply -replace="module.ec2_docker.aws_instance.app" -var-file="dev.tfvars"
```

## Segurança

- A EC2 fica em subnet privada e não recebe IP público.
- O RDS fica em subnet privada e `publicly_accessible = false`.
- O ALB é o único ponto público do ambiente dev.
- SSH não é aberto por padrão.
- O RDS aceita tráfego 3306 somente do security group da EC2.
- A EC2 usa saída HTTP/HTTPS via NAT Gateway para instalar pacotes, clonar o repositório e baixar imagens Docker.
- Nenhuma credencial real deve ser versionada.

## Observação sobre state

O backend remoto do Terraform ainda não está configurado. O state local não deve ser versionado.

Arquivos protegidos pelo `.gitignore`:

```text
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
!*.tfvars.example
crash.log
crash.*.log
```
