# Módulo Edge

Este módulo será responsável pela camada de borda.

## Recursos Futuros

- Amazon CloudFront.
- AWS WAF.
- AWS Certificate Manager em `us-east-1`.
- Integração com ALB.
- AWS Shield Standard como proteção nativa.

## Observações

Certificados ACM usados por CloudFront devem ficar em `us-east-1`. O provider com alias `edge` foi preparado para essa evolução.
