# IAM

Este documento descreve o papel do AWS Identity and Access Management no Mercantis Move2Cloud.

## Papel do IAM

IAM controla identidades, permissoes e acesso a recursos AWS. No projeto, o uso correto de IAM reduz risco de credenciais fixas e permite aplicar o principio do menor privilegio.

## Usuario IAM e IAM Role

Um usuario IAM representa uma identidade humana ou tecnica com credenciais de longo prazo, quando necessario. Uma IAM Role e uma identidade assumida temporariamente por um servico, como EC2.

Para a aplicacao, a recomendacao e usar IAM Role associada a EC2, evitando access keys fixas em arquivos, variaveis ou scripts.

## IAM Role para EC2

A EC2 deve receber uma role com permissoes minimas. Exemplos de permissoes futuras:

- envio de logs para CloudWatch Logs;
- leitura de segredos especificos no Secrets Manager;
- uso de SSM Session Manager para acesso administrativo;
- leitura de parametros especificos, se Parameter Store for adotado.

## Permissoes minimas

A role nao deve receber permissoes administrativas amplas. Cada permissao deve ter objetivo claro, escopo limitado e, quando possivel, restricao por recurso.

## Credenciais AWS

- Nao colocar access key em `.env`.
- Nao versionar credenciais no GitHub.
- Nao gravar credenciais em Dockerfile.
- Nao embutir credenciais em imagens Docker.
- Preferir IAM Role para workloads em AWS.

## Evolucoes recomendadas

- Role EC2 com permissoes de CloudWatch Logs.
- Permissao read-only para segredos especificos no Secrets Manager.
- SSM Session Manager para reduzir necessidade de SSH.
- Revisao periodica de politicas IAM.
