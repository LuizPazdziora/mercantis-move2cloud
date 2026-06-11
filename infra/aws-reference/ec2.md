# Referência de EC2

## Objetivo

Registrar a referência inicial para execução de containers em uma instância privada durante uma validação controlada.

## Diretrizes

- Instância em subnet privada.
- Acesso administrativo sem SSH público.
- Security Group permitindo entrada somente a partir da camada de balanceamento.
- Saída restrita ao necessário para atualização, imagens, logs e integração com serviços AWS.
- Containers de frontend e backend executados de forma separada.

## Observação

Esta referência não publica a aplicação automaticamente. Qualquer exposição externa depende de liberação explícita e revisão de segurança.
