# Decisões Arquiteturais

Este documento registra decisões técnicas do Mercantis Move2Cloud para orientar a evolução do MVP local e do ambiente AWS de desenvolvimento.

## Estratégia de Migração

**Decisão:** adotar replatform com refactor parcial.

**Justificativa:** a aplicação é preparada em containers e o banco de dados evolui para Amazon RDS for MariaDB na AWS, reduzindo dependência de infraestrutura local sem exigir reescrita completa.

**Impacto positivo:** permite validar o MVP localmente, separar camadas e executar uma implantação AWS de desenvolvimento com menor risco.

**Limitações:** a arquitetura local não representa alta disponibilidade nem operação produtiva.

**Evolução futura:** ampliar controles de segurança, observabilidade e disponibilidade antes de uma publicação produtiva.

## Backend em FastAPI

**Decisão:** usar Python com FastAPI para a API do MVP.

**Justificativa:** FastAPI oferece implementação objetiva de APIs REST, validação com Pydantic e documentação automática em Swagger.

**Impacto positivo:** acelera a validação dos endpoints `health`, `db-health`, `products` e `orders`.

**Limitações:** autenticação, autorização, rate limit e políticas avançadas de segurança não fazem parte desta etapa.

**Evolução futura:** adicionar autenticação e controles de acesso em fase posterior, se necessário.

## Frontend Estático com Nginx

**Decisão:** manter o frontend em HTML, CSS e JavaScript puro, servido por Nginx.

**Justificativa:** o MVP precisa de uma interface funcional e leve, sem complexidade de framework.

**Impacto positivo:** reduz dependências, simplifica build e facilita auditoria.

**Limitações:** uma interface mais complexa pode exigir framework ou pipeline de build.

**Evolução futura:** avaliar framework frontend apenas se houver aumento real de complexidade.

## Docker Compose Local

**Decisão:** usar Docker Compose para orquestrar `frontend`, `backend` e `database` localmente.

**Justificativa:** Compose simplifica execução local e reproduz a separação básica entre camadas.

**Impacto positivo:** o ambiente sobe com um único comando e mantém comunicação interna previsível.

**Limitações:** Docker Compose não substitui arquitetura produtiva com rede, balanceamento, observabilidade e segurança gerenciada.

**Evolução futura:** manter Docker Compose local para desenvolvimento e avaliar orquestração gerenciada somente se houver necessidade operacional.

## Porta Interna 3306 e Porta Local 3307

**Decisão:** manter MariaDB internamente em `3306` e publicar no host local em `3307`.

**Justificativa:** a porta `3306` costuma estar ocupada em máquinas Windows por MySQL, MariaDB, XAMPP, WAMP ou serviços locais.

**Impacto positivo:** evita conflito de porta local sem alterar a comunicação interna do backend com o banco.

**Limitações:** ferramentas locais devem usar `127.0.0.1:3307`, enquanto o backend usa `database:3306`.

**AWS:** o backend usa o endpoint privado do RDS na porta `3306`.

## Variáveis de Ambiente

**Decisão:** configurar banco, portas e CORS por variáveis de ambiente.

**Justificativa:** configurações variam por ambiente e não devem ficar fixas no código.

**Impacto positivo:** facilita execução local e a execução AWS com variáveis renderizadas no `.env` interno da EC2.

**Limitações:** valores sensíveis exigem gestão adequada e não devem ser tratados apenas por arquivos locais em ambiente AWS.

**Evolução futura:** usar AWS Secrets Manager ou SSM Parameter Store para segredos.

## Não Versionamento de `.env`

**Decisão:** manter `.env` fora do Git e versionar apenas `.env.example`.

**Justificativa:** `.env` pode conter senhas e configurações locais.

**Impacto positivo:** reduz risco de vazamento acidental de credenciais.

**Limitações:** o usuário deve criar `.env` localmente antes de executar Docker Compose.

**Evolução futura:** substituir o uso de `dev.tfvars` para segredos por serviço gerenciado em AWS.

## CORS Restrito

**Decisão:** permitir a origem local `http://localhost:8080` por padrão e usar proxy `/api` no ambiente AWS.

**Justificativa:** o frontend local precisa consumir o backend em `http://localhost:8000`; na AWS, frontend e API usam o mesmo domínio do ALB.

**Impacto positivo:** evita CORS completamente aberto durante a validação local.

**Limitações:** a origem local não representa o domínio final de uma implantação publicada.

**Evolução futura:** restringir CORS ao domínio oficial antes de uma publicação produtiva.

# Decisões AWS de Desenvolvimento

## Camada de Borda com CloudFront, WAF, Shield e ACM

**Decisão:** documentar CloudFront, AWS WAF, AWS Shield Standard e AWS Certificate Manager como camada de borda para publicação futura.

**Justificativa:** a camada de borda centraliza HTTPS, distribuição, proteção contra ataques web comuns e certificado TLS.

**Impacto positivo:** reduz exposição direta da aplicação e cria base para publicação pública controlada.

**Limitações:** adiciona configuração, custo e necessidade de validação de regras WAF e certificados.

**Evolução futura:** associar domínio, certificado ACM, distribuição CloudFront e regras WAF após aprovação de publicação.

## ALB Como Ponto de Entrada da Aplicação

**Decisão:** usar Application Load Balancer nas subnets públicas como ponto de entrada da camada de aplicação.

**Justificativa:** o ALB encaminha tráfego autorizado para a EC2 privada sem expor a instância diretamente à internet.

**Impacto positivo:** melhora segmentação, health checks e controle do tráfego HTTP atual, com caminho para HTTPS futuro.

**Limitações:** o MVP inicial pode ter apenas um host de aplicação, sem alta disponibilidade completa.

**Evolução futura:** adicionar múltiplas instâncias em subnets privadas diferentes e Auto Scaling.

## EC2 Privada com Docker no MVP AWS

**Decisão:** executar `frontend-container` e `backend-api-container` em uma EC2 privada com Docker.

**Justificativa:** preserva o empacotamento local em containers e aumenta segurança ao remover exposição direta da EC2.

**Impacto positivo:** mantém simplicidade operacional do MVP e alinha o desenho ao fluxo ALB -> EC2 privada.

**Limitações:** exige gestão operacional da instância, sistema operacional, Docker, logs e atualizações.

**Evolução futura:** avaliar ECS/Fargate se a operação exigir orquestração gerenciada.

## RDS MariaDB Privado

**Decisão:** substituir o MariaDB local por Amazon RDS for MariaDB em subnets privadas de banco.

**Justificativa:** o banco gerenciado reduz responsabilidade operacional e evita exposição direta à internet.

**Impacto positivo:** melhora isolamento, backup e monitoramento do banco.

**Limitações:** exige DB Subnet Group, Security Group correto, política de backup e cuidado com custos.

**Evolução futura:** habilitar Multi-AZ e criptografia com KMS conforme necessidade.

## NAT Gateway Para Saída da Subnet Privada

**Decisão:** documentar NAT Gateway para saída controlada da EC2 privada.

**Justificativa:** a EC2 pode precisar acessar a internet para atualizações e downloads sem receber conexões externas.

**Impacto positivo:** preserva isolamento de entrada e permite operação básica do host privado.

**Limitações:** um único NAT Gateway reduz custo, mas não oferece resiliência por zona.

**Evolução futura:** usar NAT Gateway por zona de disponibilidade em ambiente de alta disponibilidade.

## Security Groups Segmentados

**Decisão:** usar `SG-ALB`, `SG-EC2-APP` e `SG-RDS` para separar tráfego por camada.

**Justificativa:** cada camada deve aceitar apenas a origem e a porta necessárias.

**Impacto positivo:** restringe o fluxo atual a `Internet -> ALB -> EC2 privada -> RDS privado`, com CloudFront/WAF previstos apenas como evolução.

**Limitações:** regras incorretas podem expor serviços sensíveis ou bloquear a aplicação.

**Evolução futura:** automatizar validações de regras e revisar Security Groups antes de publicação.

## CloudWatch Para Logs e Métricas

**Decisão:** recomendar CloudWatch para logs, métricas e alarmes.

**Justificativa:** a operação em AWS precisa de rastreabilidade para aplicação, EC2, ALB e RDS. WAF entra na evolução de borda.

**Impacto positivo:** melhora diagnóstico de falhas e acompanhamento de disponibilidade.

**Limitações:** exige configuração de coleta, retenção, alarmes e controle de custos.

**Evolução futura:** criar dashboards e alarmes formais antes de publicação pública.

## Secrets Manager Como Evolução

**Decisão:** recomendar AWS Secrets Manager para segredos em AWS.

**Justificativa:** senhas e tokens não devem ficar em arquivos versionados, imagens Docker ou comandos de execução.

**Impacto positivo:** reduz risco de vazamento e permite acesso controlado por IAM Role.

**Limitações:** adiciona custo e requer integração operacional.

**Evolução futura:** conceder leitura apenas à role da aplicação e planejar rotação de segredos.

## S3 Opcional Para Apoio

**Decisão:** documentar Amazon S3 como componente auxiliar/opcional.

**Justificativa:** S3 pode apoiar artefatos, arquivos estáticos futuros ou backups exportados, mas não é dependência obrigatória do MVP.

**Impacto positivo:** deixa clara uma possibilidade de evolução sem acoplar a aplicação ao serviço nesta etapa.

**Limitações:** exige política de acesso, criptografia, versionamento e bloqueio de acesso público quando utilizado.

**Evolução futura:** avaliar uso de S3 apenas se houver necessidade concreta de armazenamento de objetos.

## Não Uso Inicial de ECS/Fargate

**Decisão:** não adotar ECS/Fargate na referência inicial do MVP.

**Justificativa:** o objetivo atual é validar uma implantação simples com EC2 privada e Docker.

**Impacto positivo:** reduz complexidade e mantém proximidade com o ambiente local.

**Limitações:** a EC2 exige mais responsabilidade operacional do que um serviço gerenciado de containers.

**Evolução futura:** migrar para ECS/Fargate se houver demanda por orquestração gerenciada.

## Não Uso Inicial de Kubernetes

**Decisão:** não usar Kubernetes no MVP AWS.

**Justificativa:** Kubernetes adicionaria complexidade incompatível com a etapa atual.

**Impacto positivo:** mantém a arquitetura objetiva e adequada ao escopo do MVP.

**Limitações:** não há recursos nativos de orquestração avançada, autoscaling de pods ou service mesh.

**Evolução futura:** reavaliar somente se escala e complexidade justificarem.

## Expansão Futura Para Alta Disponibilidade

**Decisão:** reservar a segunda zona de disponibilidade para expansão futura.

**Justificativa:** o diagrama prevê subnets 1B para aplicação e banco, mas o MVP não promete alta disponibilidade completa.

**Impacto positivo:** cria caminho técnico para evolução sem superdimensionar a primeira implantação.

**Limitações:** a versão inicial pode ter pontos únicos de falha, como uma EC2 e um NAT Gateway.

**Evolução futura:** usar múltiplas EC2, Auto Scaling, NAT Gateway por AZ e RDS Multi-AZ.

## Publicação Controlada

**Decisão:** manter a publicação do MVP controlada pelo ALB e documentar validações antes de qualquer ampliação de exposição.

**Justificativa:** antes de uma publicação produtiva, são necessários HTTPS, CORS restrito, logs, backups, revisão de Security Groups e plano de rollback.

**Impacto positivo:** reduz risco de vazamento, indisponibilidade e acesso indevido.

**Limitações:** o ambiente atual usa HTTP/80 e deve ser tratado como ambiente de desenvolvimento.

**Evolução futura:** executar checklist de publicação, registrar evidências e liberar acesso de forma controlada.
