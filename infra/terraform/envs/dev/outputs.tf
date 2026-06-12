output "vpc_id" {
  description = "ID da VPC criada."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas."
  value       = module.network.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs das subnets privadas de aplicação."
  value       = module.network.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs das subnets privadas de banco."
  value       = module.network.private_db_subnet_ids
}

output "alb_dns_name" {
  description = "DNS público do Application Load Balancer."
  value       = module.alb.alb_dns_name
}

output "rds_endpoint" {
  description = "Endpoint completo do RDS MariaDB."
  value       = module.rds.rds_endpoint
}

output "ec2_private_ip" {
  description = "IP privado da EC2 de aplicação."
  value       = module.ec2_docker.ec2_private_ip
}
