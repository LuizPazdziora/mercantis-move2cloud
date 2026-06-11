# Decisões Arquiteturais

## Estratégia de migração

**Decisão:** adotar replatform com refactor parcial.

**Justificativa:** a aplicação é preparada em containers e o banco de dados é planejado para evolução para Amazon RDS for MariaDB, reduzindo dependência de infraestrutura local sem exigir reescrita completa.

**Impacto positivo:** permite validar o MVP localmente, separar camadas e criar caminho de evolução para AWS com menor risco.

**Limitações e pontos de atenção:** a arquitetura local não representa alta disponibilidade nem operação produtiva. A implantação AWS ainda precisa de desenho formal de rede, segurança, observabilidade e custos.

## Backend em FastAPI

**Decisão:** usar Python com FastAPI para a API do MVP.

**Justificativa:** FastAPI oferece implementação simples de APIs REST, validação com Pydantic e documentação automática em Swagger.

**Impacto positivo:** acelera a validação do MVP e facilita testes dos endpoints `health`, `db-health`, `products` e `orders`.

**Limitações e pontos de atenção:** autenticação, autorização, rate limit e políticas avançadas de segurança não fazem parte desta etapa.

## Banco MariaDB

**Decisão:** usar MariaDB no ambiente local e planejar Amazon RDS for MariaDB para produção futura.

**Justificativa:** MariaDB atende ao modelo relacional do MVP e mantém compatibilidade com o serviço gerenciado planejado na AWS.

**Impacto positivo:** reduz diferenças entre desenvolvimento local e banco planejado para cloud.

**Limitações e pontos de atenção:** scripts `init.sql` e `seed.sql` só são aplicados automaticamente quando o volume do banco é criado. Volumes antigos podem exigir ajuste manual ou recriação controlada.

## Docker Compose local

**Decisão:** usar Docker Compose para orquestrar `frontend`, `backend` e `database`.

**Justificativa:** Compose simplifica a execução local e reproduz a separação básica entre camadas.

**Impacto positivo:** o ambiente sobe com um único comando e mantém comunicação interna previsível entre serviços.

**Limitações e pontos de atenção:** Docker Compose não substitui uma arquitetura produtiva com alta disponibilidade, balanceamento, observabilidade e automação de deploy.

## Frontend estático com Nginx

**Decisão:** manter o frontend em HTML, CSS e JavaScript puro, servido por Nginx.

**Justificativa:** o MVP precisa de uma interface funcional e leve, sem complexidade de framework.

**Impacto positivo:** reduz dependências, simplifica build e torna a interface fácil de auditar.

**Limitações e pontos de atenção:** uma evolução futura pode exigir framework ou pipeline de build se a interface crescer em complexidade.

## Porta interna 3306 e porta local 3307

**Decisão:** manter MariaDB internamente em `3306` e publicar no host local em `3307`.

**Justificativa:** a porta `3306` costuma estar ocupada em máquinas Windows por MySQL, MariaDB, XAMPP, WAMP ou serviços locais.

**Impacto positivo:** evita conflito de porta local sem alterar a comunicação interna do backend com o banco.

**Limitações e pontos de atenção:** ferramentas locais devem usar `127.0.0.1:3307`, enquanto o backend usa `database:3306`.

## Variáveis de ambiente

**Decisão:** configurar banco, portas e CORS por variáveis de ambiente.

**Justificativa:** configurações variam por ambiente e não devem ficar fixas no código.

**Impacto positivo:** facilita execução local e prepara o projeto para ambientes futuros.

**Limitações e pontos de atenção:** valores sensíveis devem ser tratados por mecanismos próprios em AWS, como Secrets Manager, e não por arquivos versionados.

## Não versionamento de `.env`

**Decisão:** manter `.env` fora do Git e versionar apenas `.env.example`.

**Justificativa:** `.env` pode conter senhas e configurações locais.

**Impacto positivo:** reduz risco de vazamento acidental de credenciais.

**Limitações e pontos de atenção:** o usuário deve criar `.env` localmente antes de executar Docker Compose.

## CORS restrito ao frontend local

**Decisão:** permitir a origem `http://localhost:8080` por padrão.

**Justificativa:** o frontend local precisa consumir o backend em `http://localhost:8000`.

**Impacto positivo:** evita CORS completamente aberto durante a validação local.

**Limitações e pontos de atenção:** em uma futura implantação AWS, as origens devem ser substituídas pelos domínios autorizados e revisadas junto com a camada de segurança.

## Banco privado na arquitetura AWS futura

**Decisão:** planejar o banco AWS como Amazon RDS for MariaDB em subnet privada.

**Justificativa:** o banco não deve ser acessível diretamente pela internet.

**Impacto positivo:** reduz superfície de ataque e mantém o backend como única camada autorizada a acessar dados.

**Limitações e pontos de atenção:** a futura implantação precisa definir VPC, subnets privadas, Security Groups, backups, monitoramento e estratégia de acesso operacional.

## Fora do escopo desta etapa

**Decisão:** não adicionar autenticação, pagamento, logística, antifraude, usuários reais, Kubernetes, ECS, Lambda ou API Gateway nesta etapa.

**Justificativa:** o fechamento atual é da versão local do MVP, com foco em validação funcional, documentação e preparação técnica.

**Impacto positivo:** mantém o escopo controlado e reduz risco de introduzir complexidade prematura.

**Limitações e pontos de atenção:** esses temas podem ser avaliados em fases futuras, após estabilização da base local e definição da arquitetura AWS.

# Decisões AWS de Referência

As decisões abaixo documentam a arquitetura AWS alvo para uma implantação simples, segura e controlada. Nenhum recurso real foi criado nesta etapa.

## Uso de EC2 + Docker no MVP AWS

**Decisão:** executar os containers `frontend` e `backend` em Amazon EC2 com Docker.

**Justificativa:** a abordagem preserva o empacotamento local, reduz mudanças na aplicação e permite validar a migração com menor complexidade inicial.

**Impacto positivo:** acelera a transição para AWS mantendo a estratégia de replatform com refactor parcial.

**Limitações:** exige gestão operacional da EC2, atualizações do sistema, hardening, logs e controle manual de capacidade.

**Evolução futura:** avaliar Application Load Balancer, Auto Scaling e ECS/Fargate quando houver necessidade de maior automação e resiliência.

## Uso de RDS MariaDB privado

**Decisão:** substituir o MariaDB local por Amazon RDS for MariaDB em subnet privada.

**Justificativa:** o RDS fornece banco gerenciado, backups automáticos e melhor isolamento operacional sem alterar o modelo relacional do MVP.

**Impacto positivo:** reduz exposição do banco e remove a necessidade de executar banco em container na AWS.

**Limitações:** envolve custo gerenciado, configuração de subnet group, políticas de backup e atenção a migrações de schema.

**Evolução futura:** habilitar Multi-AZ, criptografia gerenciada por KMS e integração com Secrets Manager.

## Uso de VPC com subnets públicas e privadas

**Decisão:** documentar VPC dedicada com subnets públicas para entrada controlada e subnets privadas para banco.

**Justificativa:** a separação de rede reduz superfície de ataque e cria base para evolução segura.

**Impacto positivo:** permite posicionar EC2 e RDS em camadas distintas, com rotas e regras coerentes.

**Limitações:** o MVP inicial ainda não entrega alta disponibilidade completa.

**Evolução futura:** manter EC2 em subnet privada atrás de Application Load Balancer público.

## Uso de Security Groups segmentados

**Decisão:** definir Security Groups separados para EC2 e RDS.

**Justificativa:** regras por camada permitem controlar origem, destino e porta com precisão.

**Impacto positivo:** a porta `3306` do RDS pode ser liberada somente para o Security Group da EC2.

**Limitações:** regras incorretas podem expor serviços sensíveis ou bloquear a aplicação.

**Evolução futura:** revisar regras periodicamente e automatizar validações de configuração.

## Uso futuro de Secrets Manager

**Decisão:** recomendar AWS Secrets Manager para segredos em evolução AWS.

**Justificativa:** senhas e tokens não devem ficar em arquivos versionados, Dockerfile, imagens ou comandos de deploy.

**Impacto positivo:** reduz risco de vazamento e permite controle de acesso via IAM Role.

**Limitações:** adiciona custo e exige integração operacional ou de código.

**Evolução futura:** conceder leitura apenas à role da aplicação e planejar rotação de segredos.

## Uso futuro de CloudWatch

**Decisão:** recomendar CloudWatch Logs e Metrics para observabilidade.

**Justificativa:** a operação em AWS precisa de logs, métricas e alarmes para diagnóstico e resposta a incidentes.

**Impacto positivo:** melhora rastreabilidade de falhas em EC2, containers, backend e RDS.

**Limitações:** exige configuração de agente, retenção, alarmes e controle de custos.

**Evolução futura:** criar painéis, alarmes e procedimentos de resposta operacional.

## Não uso inicial de ECS/Fargate

**Decisão:** não adotar ECS/Fargate na primeira referência AWS.

**Justificativa:** o objetivo inicial é validar uma implantação simples com EC2 + Docker, mantendo baixa complexidade.

**Impacto positivo:** reduz curva de configuração e facilita comparação com o ambiente local.

**Limitações:** a EC2 exige mais responsabilidade operacional do que um serviço gerenciado de containers.

**Evolução futura:** migrar para ECS/Fargate se houver necessidade de orquestração gerenciada.

## Não uso inicial de Kubernetes

**Decisão:** não usar Kubernetes no MVP AWS.

**Justificativa:** Kubernetes adicionaria complexidade incompatível com a necessidade atual do projeto.

**Impacto positivo:** mantém arquitetura objetiva e alinhada ao escopo de validação.

**Limitações:** não há recursos nativos de orquestração avançada, autoscaling de pods ou service mesh.

**Evolução futura:** reavaliar somente se a escala e a complexidade justificarem.

## Não exposição pública sem validação

**Decisão:** não publicar a aplicação em ambiente aberto sem validação técnica e aprovação.

**Justificativa:** antes de exposição pública, são necessários HTTPS, CORS restrito, logs, backups, revisão de Security Groups e plano de rollback.

**Impacto positivo:** reduz risco de vazamento, indisponibilidade e acesso indevido.

**Limitações:** a aplicação permanece restrita até concluir os controles mínimos.

**Evolução futura:** executar checklist de publicação, registrar evidências e liberar o acesso de forma controlada.
