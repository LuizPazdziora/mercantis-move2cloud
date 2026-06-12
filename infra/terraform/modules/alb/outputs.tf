output "alb_dns_name" {
  description = "DNS público do Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "ARN do Application Load Balancer."
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "ARN do target group do frontend."
  value       = aws_lb_target_group.frontend.arn
}
