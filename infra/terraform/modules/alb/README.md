# Módulo ALB

Este módulo cria o Application Load Balancer público usado como ponto de entrada do ambiente dev.

## Recursos

- Application Load Balancer em subnets públicas.
- Target Group apontando para a EC2 privada.
- Listener HTTP `80`.
- Health check em `/`, validando o frontend servido pelo Nginx.

## Observações

O ALB encaminha tráfego para o frontend Nginx na EC2 pela porta `80`. O health check do Target Group valida `/`, que confirma a disponibilidade da interface estática. O Nginx serve a interface e encaminha `/api/*` para o backend FastAPI dentro da rede Docker da instância.

Target Groups da AWS possuem limite de 32 caracteres no campo `name`. Por isso, o nome físico do Target Group usa prefixo curto, como `mercantis-dev-fe-tg`, enquanto as tags continuam com nomes completos e descritivos do projeto.
