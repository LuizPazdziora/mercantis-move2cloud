output "planned_resources" {
  description = "Recursos planejados para o módulo Observability."
  value       = local.planned_resources
}

# Outputs futuros:
# - log_group_names
# - alarm_names
# - dashboard_names
