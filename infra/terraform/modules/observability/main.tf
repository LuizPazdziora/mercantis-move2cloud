# Módulo observability.
#
# Futuramente este módulo criará:
# - CloudWatch Logs
# - métricas
# - alarmes
# - dashboards, se necessário

locals {
  planned_resources = [
    "cloudwatch_log_groups",
    "cloudwatch_metrics",
    "cloudwatch_alarms",
    "cloudwatch_dashboards",
  ]
}
