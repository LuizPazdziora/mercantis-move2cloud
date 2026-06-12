locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-sg-alb"
  description = "Permite acesso HTTP publico ao Application Load Balancer."
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-sg-alb"
  })
}

resource "aws_security_group" "ec2_app" {
  name        = "${local.name_prefix}-sg-ec2-app"
  description = "Permite trafego do ALB para a EC2 privada da aplicacao."
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-sg-ec2-app"
  })
}

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-sg-rds"
  description = "Permite acesso MariaDB somente a partir da EC2 da aplicacao."
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${local.name_prefix}-sg-rds"
  })
}

resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  description       = "HTTP publico temporario para avaliacao."
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = var.alb_ingress_cidrs
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_https_ingress" {
  count = var.enable_https_ingress ? 1 : 0

  type              = "ingress"
  description       = "HTTPS preparado para evolucao futura com ACM."
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = var.alb_ingress_cidrs
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_to_ec2_app" {
  type                     = "egress"
  description              = "Saida do ALB para o frontend na EC2."
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_app.id
  security_group_id        = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ec2_app_from_alb" {
  type                     = "ingress"
  description              = "Entrada apenas do ALB para o frontend."
  from_port                = var.app_port
  to_port                  = var.app_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2_app.id
}

resource "aws_security_group_rule" "ec2_app_to_rds" {
  type                     = "egress"
  description              = "Saida da aplicacao para o RDS MariaDB."
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds.id
  security_group_id        = aws_security_group.ec2_app.id
}

resource "aws_security_group_rule" "ec2_app_http_egress" {
  type              = "egress"
  description       = "Saida HTTP via NAT para instalacao de pacotes e clone do repositorio."
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_app.id
}

resource "aws_security_group_rule" "ec2_app_https_egress" {
  type              = "egress"
  description       = "Saida HTTPS via NAT para instalacao de pacotes e clone do repositorio."
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_app.id
}

resource "aws_security_group_rule" "ec2_app_ssh_ingress" {
  count = length(var.ssh_allowed_cidrs)

  type              = "ingress"
  description       = "SSH restrito e opcional; manter vazio quando nao houver bastion/VPN."
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.ssh_allowed_cidrs[count.index]]
  security_group_id = aws_security_group.ec2_app.id
}

resource "aws_security_group_rule" "rds_from_ec2_app" {
  type                     = "ingress"
  description              = "MariaDB somente a partir da EC2 da aplicacao."
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_app.id
  security_group_id        = aws_security_group.rds.id
}
