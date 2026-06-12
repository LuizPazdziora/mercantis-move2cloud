# Plano de Implantação AWS

Este plano descreve o fluxo operacional do ambiente AWS de desenvolvimento do Mercantis Move2Cloud e os controles que devem ser mantidos para evolução. A infraestrutura atual é provisionada por Terraform, com ALB público, EC2 privada com Docker Compose e Amazon RDS for MariaDB privado.

## Premissas

- A aplicação local continua usando Docker Compose.
- O ambiente AWS usa EC2 privada com Docker Compose para frontend e backend.
- O banco em AWS é Amazon RDS for MariaDB em subnet privada de banco.
- O acesso externo atual ocorre pelo Application Load Balancer público em HTTP/80.
- A EC2 não recebe tráfego direto da internet.
- RDS e EC2 não devem ficar públicos.
- CloudFront, WAF, ACM, HTTPS e Route 53 permanecem como evolução futura.

## Plano Operacional

| Etapa | Objetivo | Ação esperada | Resultado esperado | Risco principal | Como validar |
| --- | --- | --- | --- | --- | --- |
| 1. Validar MVP local | Confirmar base funcional | Executar Docker Compose e endpoints locais | Frontend, backend e banco locais respondendo | Levar falha local para AWS | Validar `/health`, `/db-health`, `/products`, `/orders` e frontend |
| 2. Criar VPC | Isolar a rede do projeto | Planejar VPC `10.0.0.0/16` em `sa-east-1` | Rede dedicada definida | CIDR conflitante | Conferir desenho e intervalos |
| 3. Criar subnets públicas e privadas | Separar entrada, aplicação e banco | Definir subnets públicas, privadas de aplicação e privadas de banco | Camadas separadas por rede | Recurso sensível em subnet pública | Revisar CIDRs e associações |
| 4. Criar Internet Gateway | Permitir entrada pública controlada | Associar Internet Gateway à VPC | Subnets públicas com saída/entrada controlada | Rota pública aplicada em subnet privada | Conferir route tables |
| 5. Criar NAT Gateway | Permitir saída controlada da aplicação privada | Posicionar NAT Gateway na camada pública | Host privado com saída controlada | Custo ou ponto único de falha no MVP | Validar rota privada para NAT |
| 6. Criar Route Tables | Controlar rotas por camada | Associar rotas públicas ao IGW e privadas ao NAT quando necessário | Tráfego separado por finalidade | Banco com rota pública | Revisar associações |
| 7. Criar Security Groups | Segmentar tráfego | Definir `SG-ALB`, `SG-EC2-APP` e `SG-RDS` | Comunicação mínima entre camadas | Porta sensível aberta | Conferir origem, destino e porta |
| 8. Criar RDS MariaDB privado | Substituir banco local | Planejar RDS em subnets privadas de banco | Banco gerenciado privado | RDS público ou sem backup | Validar public accessibility, subnet group, backup e SG |
| 9. Criar EC2 em subnet privada | Hospedar containers | Posicionar EC2 na subnet privada de aplicação | Host Docker sem exposição direta | Instância posicionada em camada incorreta | Conferir subnet, IP público e regras de entrada |
| 10. Configurar IAM Role | Evitar access keys fixas | Associar role mínima à EC2 | Permissões controladas | Permissão ampla demais | Revisar políticas IAM |
| 11. Instalar Docker na EC2 | Preparar runtime | Instalar Docker conforme padrão aprovado | Host pronto para containers | Instalação sem rastreabilidade | Validar serviço Docker |
| 12. Configurar variáveis para RDS | Conectar backend ao banco | Definir `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` fora do Git | Backend preparado para RDS | Segredo exposto | Revisar origem das variáveis |
| 13. Executar containers | Subir aplicação | Executar `frontend-container` e `backend-api-container` | Aplicação ativa na EC2 | Usar container de banco na AWS | Validar containers e logs |
| 14. Configurar ALB | Publicar entrada da aplicação | Criar listeners e target group para EC2 privada | ALB encaminhando para aplicação | Health check incorreto | Validar target healthy |
| 15. Configurar CloudFront/WAF/ACM | Evolução futura de borda segura | Associar HTTPS, regras WAF e distribuição quando aprovado | Entrada pública protegida | Certificado ou regra incorreta | Validar HTTPS e regras WAF |
| 16. Validar ALB -> EC2 -> RDS | Confirmar fluxo fim a fim | Testar acesso externo e conexão ao banco | Aplicação responde com banco privado | Falha de rota ou SG | Validar frontend, API e `/db-health` |
| 17. Validar logs e métricas | Garantir rastreabilidade | Conferir CloudWatch para aplicação e infraestrutura | Evidências disponíveis | Falha sem diagnóstico | Revisar logs, métricas e alarmes |
| 18. Aplicar checklist de segurança | Reduzir risco antes de liberação | Executar `docs/aws/checklist-aws.md` | Riscos críticos tratados | Publicação insegura | Registrar evidências |
| 19. Liberar ambiente após aprovação | Controlar publicação | Liberar somente com validação formal | Ambiente publicado de forma controlada | Exposição prematura | Registrar aprovação e plano de rollback |

## Critérios de Liberação

- Nenhuma credencial real no repositório.
- `.env` fora do versionamento.
- EC2 em subnet privada.
- RDS em subnet privada e sem IP público.
- ALB em subnets públicas.
- Porta `3306` permitida somente da aplicação para o RDS.
- HTTPS, certificado e domínio próprio planejados para evolução futura.
- CORS restrito ao domínio correto antes de uma publicação produtiva.
- Logs, métricas, backup e rollback documentados.
