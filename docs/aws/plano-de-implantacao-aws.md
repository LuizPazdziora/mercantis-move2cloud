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
