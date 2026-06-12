output "rds_endpoint" {
  description = "Endpoint completo do RDS MariaDB."
  value       = aws_db_instance.mariadb.endpoint
}

output "rds_address" {
  description = "Endereço DNS do RDS MariaDB sem porta."
  value       = aws_db_instance.mariadb.address
}

output "rds_port" {
  description = "Porta do RDS MariaDB."
  value       = aws_db_instance.mariadb.port
}

output "rds_instance_id" {
  description = "Identificador da instância RDS."
  value       = aws_db_instance.mariadb.id
}
