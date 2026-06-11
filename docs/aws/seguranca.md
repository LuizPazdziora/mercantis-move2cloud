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
