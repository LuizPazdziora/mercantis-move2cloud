# IAM

Este documento descreve o papel do AWS Identity and Access Management no Mercantis Move2Cloud.

## Papel do IAM

IAM controla identidades, permissões e acesso a recursos AWS. No projeto, o uso correto de IAM reduz risco de credenciais fixas e permite aplicar o princípio do menor privilégio.

## Usuário IAM e IAM Role

Um usuário IAM representa uma identidade humana ou técnica com credenciais de longo prazo, quando necessário. Uma IAM Role é uma identidade assumida temporariamente por um serviço, como EC2.

Para a aplicação, a recomendação é usar IAM Role associada à EC2 privada, evitando access keys fixas em arquivos, variáveis ou scripts.

## IAM Role Para EC2

A EC2 deve receber uma role com permissões mínimas. Exemplos de permissões futuras:

- envio de logs para CloudWatch Logs;
- leitura de segredos específicos no Secrets Manager;
- uso de SSM Session Manager para acesso administrativo;
- leitura de parâmetros específicos, se Parameter Store for adotado.

## Permissões Mínimas

A role não deve receber permissões administrativas amplas. Cada permissão deve ter objetivo claro, escopo limitado e, quando possível, restrição por recurso.

## Credenciais AWS

- Não colocar access key em `.env`.
- Não versionar credenciais no GitHub.
- Não gravar credenciais em Dockerfile.
- Não embutir credenciais em imagens Docker.
- Preferir IAM Role para workloads em AWS.

## Evoluções Recomendadas

- Role EC2 com permissões de CloudWatch Logs.
- Permissão read-only para segredos específicos no Secrets Manager.
- SSM Session Manager para reduzir necessidade de SSH.
- Revisão periódica de políticas IAM.
