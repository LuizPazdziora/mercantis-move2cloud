# Plano de Implantação AWS

Este plano descreve uma referência inicial para futura implantação controlada do Mercantis Move2Cloud na AWS. Nenhum ambiente deve ficar público ou online sem aprovação explícita.

## Etapas previstas

1. Criar VPC dedicada com subnets públicas e privadas.
2. Definir tabelas de rota e acesso de saída conforme necessidade operacional.
3. Implantar banco Amazon RDS for MariaDB em subnet privada, sem IP público.
4. Implantar camada de aplicação em subnet privada.
5. Configurar entrada HTTPS controlada para a aplicação.
6. Aplicar Security Groups por camada.
7. Validar logs, métricas e trilhas de auditoria.
8. Executar testes funcionais mínimos.
9. Registrar evidências técnicas.
10. Desligar ou remover recursos temporários quando a validação terminar.

## Critérios de liberação

- Nenhuma credencial real no repositório.
- RDS sem acesso público.
- Acesso ao banco permitido somente pelo backend.
- Tráfego público usando HTTPS.
- Custos monitorados antes e depois da validação.
- Plano de desativação revisado.

## Plano operacional detalhado

Este plano é apenas documental. Nenhum comando AWS CLI, Terraform ou CloudFormation deve ser executado nesta etapa.

| Etapa | Objetivo | Ação esperada | Resultado esperado | Risco principal | Como validar |
| --- | --- | --- | --- | --- | --- |
| 1. Preparação do repositório | Garantir base versionada e sem segredos | Revisar branch, `.gitignore`, `.env.example` e documentação | Repositório pronto para referência de deploy | Segredos acidentais no Git | Verificar `git status`, `.gitignore` e ausência de `.env` versionado |
| 2. Validação local | Confirmar MVP funcional antes da AWS | Executar Docker Compose localmente | Frontend, backend e banco locais respondendo | Levar erro local para AWS | Validar `/health`, `/db-health`, `/products`, `/orders` e frontend |
| 3. Criação da VPC | Isolar a rede do projeto | Planejar VPC `10.0.0.0/16` | Rede dedicada definida | CIDR conflitante | Conferir desenho de rede e intervalos |
| 4. Criação das subnets | Separar camadas públicas e privadas | Planejar subnets públicas e privadas em duas zonas | Subnets adequadas para EC2 e RDS | RDS sem subnets em zonas distintas | Conferir DB subnet group planejado |
| 5. Criação das route tables | Controlar tráfego de entrada e saída | Associar rota pública ao Internet Gateway e manter privadas sem exposição direta | Subnets públicas acessíveis e privadas isoladas | Rota pública aplicada em subnet privada | Revisar associações das route tables |
| 6. Criação dos Security Groups | Segmentar acesso por camada | Definir `SG-EC2` e `SG-RDS` | Regras restritivas por origem | Porta `3306` aberta para internet | Conferir origem das regras e portas |
| 7. Criação do RDS MariaDB privado | Substituir banco local por serviço gerenciado | Planejar RDS em subnets privadas, sem acesso público | Banco privado disponível para backend | RDS público ou sem backup | Validar public accessibility, subnets, backup e Security Group |
| 8. Criação da EC2 | Hospedar containers Docker | Planejar EC2 com IAM Role e Security Group restritivo | Host de aplicação preparado | EC2 com acesso administrativo amplo | Conferir role, portas e atualização do sistema |
| 9. Instalação do Docker na EC2 | Preparar runtime de containers | Instalar Docker conforme padrão aprovado | Docker disponível para frontend e backend | Instalação manual sem rastreabilidade | Validar versão do Docker e serviço ativo |
| 10. Configuração das variáveis | Conectar backend ao RDS | Definir `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` fora do Git | Backend configurado sem segredos versionados | Senha exposta em arquivo ou imagem | Revisar origem das variáveis e permissões |
| 11. Execução dos containers | Subir aplicação na EC2 | Executar frontend e backend sem container de banco | Containers ativos na EC2 | Usar banco local em vez de RDS | Validar containers e variáveis efetivas |
| 12. Teste EC2 -> RDS | Confirmar conectividade privada | Testar conexão da EC2 ao endpoint do RDS na porta `3306` | Conexão permitida apenas pela rede privada | Falha de Security Group ou rota | Validar conexão e negar acesso externo |
| 13. Teste do backend | Confirmar API em AWS | Validar endpoints do FastAPI | API responde e acessa banco | Erro de configuração de banco | Validar `/health` e `/db-health` |
| 14. Teste do frontend | Confirmar experiência web | Acessar interface pelo endereço autorizado | Frontend carrega e consome API | CORS incorreto | Validar navegador e chamadas HTTP |
| 15. Validação de logs | Garantir rastreabilidade | Conferir logs de containers, EC2 e RDS | Evidências disponíveis | Falha sem diagnóstico | Revisar CloudWatch ou plano de coleta |
| 16. Checklist de segurança | Revisar riscos antes de liberação | Executar checklist AWS | Riscos críticos tratados | Publicação insegura | Conferir `docs/aws/checklist-aws.md` |
| 17. Liberação controlada | Publicar somente com aprovação | Validar HTTPS, domínio, CORS, backups e evidências | Ambiente liberado de forma controlada | Exposição prematura | Registrar aprovação e evidências |

## Premissas

- O banco em AWS é Amazon RDS for MariaDB, não container Docker.
- A EC2 executa apenas os containers de aplicação.
- O RDS permanece em subnet privada.
- Nenhum recurso deve ser publicado sem validação de segurança.
- A exposição pública futura deve usar HTTPS.
