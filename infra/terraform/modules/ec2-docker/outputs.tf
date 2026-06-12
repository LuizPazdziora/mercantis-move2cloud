output "ec2_instance_id" {
  description = "ID da instância EC2 privada."
  value       = aws_instance.app.id
}

output "ec2_private_ip" {
  description = "IP privado da EC2 de aplicação."
  value       = aws_instance.app.private_ip
}

output "iam_role_name" {
  description = "Nome da IAM Role associada à EC2."
  value       = aws_iam_role.ec2.name
}
