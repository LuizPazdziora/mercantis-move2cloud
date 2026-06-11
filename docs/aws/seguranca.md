# Segurança

## Princípios

- Privilégio mínimo para acessos humanos e técnicos.
- Separação entre camadas pública, aplicação e banco.
- Banco de dados privado.
- Credenciais fora do código-fonte.
- Logs e auditoria habilitados conforme a etapa de implantação.

## Controles mínimos

- HTTPS para qualquer exposição pública autorizada.
- Security Groups restritivos por origem.
- Porta 3306 liberada somente entre backend e banco.
- Porta 22 fechada para a internet.
- Uso de variáveis de ambiente no ambiente local.
- Uso planejado de serviço seguro para credenciais em AWS.
- S3 sem acesso público para evidências, logs e artefatos privados.

## Restrições

- Não usar credenciais reais em arquivos versionados.
- Não publicar `.env`.
- Não usar dados reais de clientes no MVP.
- Não manter ambiente público sem liberação explícita.

## Controles de segurança para a arquitetura AWS

### Princípio do menor privilégio

Permissões humanas e técnicas devem ser concedidas somente para o que for necessário. A EC2 deve usar IAM Role com escopo mínimo, evitando usuários administrativos, access keys fixas e permissões amplas.

### Separação de rede

A arquitetura deve separar subnets públicas e privadas. A camada exposta ao usuário fica na área pública controlada, enquanto o banco permanece em subnet privada. O RDS não deve receber tráfego direto da internet.

### RDS privado

O Amazon RDS for MariaDB deve ser criado com `Public accessibility` desabilitado. A porta `3306` deve aceitar conexão somente a partir do Security Group da EC2.

### Security Groups

Security Groups devem ser usados como firewall por camada:

- `SG-EC2`: entrada HTTP/HTTPS conforme liberação controlada e SSH restrito por IP, se SSH for necessário.
- `SG-RDS`: entrada `3306` somente da origem `SG-EC2`.

Não deve existir regra liberando MariaDB para `0.0.0.0/0`.

### IAM Role para EC2

A EC2 deve usar IAM Role. A role pode evoluir para permitir envio de logs ao CloudWatch, leitura de segredos específicos no Secrets Manager e acesso via SSM Session Manager.

### Segredos e variáveis

O arquivo `.env` é aceito apenas para desenvolvimento local e não deve ser versionado. Credenciais reais não devem ser gravadas no GitHub, em Dockerfile, em imagens Docker ou em scripts de inicialização.

Em AWS, a evolução recomendada é armazenar senhas no AWS Secrets Manager e conceder leitura apenas à role da aplicação.

### Acesso administrativo

SSH deve ser evitado ou restringido a IPs autorizados. A evolução recomendada é usar AWS Systems Manager Session Manager para reduzir a exposição da porta `22`.

### CORS

Em produção, CORS deve ser restrito ao domínio real da aplicação. Configurações abertas, como permitir todas as origens, não devem ser usadas em ambiente publicado.

### HTTPS

HTTPS é obrigatório antes de qualquer exposição pública real. A arquitetura pode evoluir para Application Load Balancer com certificado gerenciado pelo ACM.

### Logs e métricas

CloudWatch deve ser usado para logs e métricas da EC2, containers, aplicação e RDS. Alarmes devem ser planejados para indisponibilidade, CPU elevada, armazenamento baixo e falhas de health check.

## Checklist de riscos

- RDS público.
- Porta `3306` aberta para internet.
- SSH aberto para `0.0.0.0/0`.
- Credenciais no repositório.
- `.env` versionado.
- CORS aberto em produção.
- Ausência de backup do RDS.
- Ausência de logs e métricas.
- Falta de HTTPS antes de publicação.
- Permissões IAM amplas ou administrativas para a aplicação.
