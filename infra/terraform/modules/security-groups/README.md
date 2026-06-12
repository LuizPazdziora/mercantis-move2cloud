# Módulo Security Groups

Este módulo cria os Security Groups principais da arquitetura AWS do MVP.

## Regras

- Internet -> ALB: HTTP `80` temporário para avaliação.
- ALB -> EC2 APP: porta `80`.
- EC2 APP -> RDS: porta `3306`.
- EC2 APP -> internet via NAT Gateway: portas `80` e `443` para instalação de pacotes, clone do repositório e download de imagens Docker.
- SSH: fechado por padrão, com lista opcional `ssh_allowed_cidrs`.

## Observações

O RDS nunca aceita `3306` de `0.0.0.0/0`. A EC2 privada recebe tráfego de entrada somente do Security Group do ALB.
