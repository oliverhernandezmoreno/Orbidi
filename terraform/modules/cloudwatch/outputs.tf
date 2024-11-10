# ARN de la alarma de CPU
output "cpu_utilization_alarm_arn" {
  description = "ARN de la alarma de CloudWatch para la utilización de CPU"
  value       = aws_cloudwatch_metric_alarm.cpu_utilization_alarm.arn
  condition   = var.enable_cpu_alarm
}

# Nombre de la alarma de CPU
output "cpu_utilization_alarm_name" {
  description = "Nombre de la alarma de CloudWatch para la utilización de CPU"
  value       = aws_cloudwatch_metric_alarm.cpu_utilization_alarm.alarm_name
  condition   = var.enable_cpu_alarm
}

# ARN de la alarma de ALB
output "alb_healthy_host_count_alarm_arn" {
  description = "ARN de la alarma de CloudWatch para el conteo de hosts saludables en el ALB"
  value       = aws_cloudwatch_metric_alarm.alb_healthy_host_count.arn
  condition   = var.enable_alb_alarm
}

# Nombre de la alarma de ALB
output "alb_healthy_host_count_alarm_name" {
  description = "Nombre de la alarma de CloudWatch para el conteo de hosts saludables en el ALB"
  value       = aws_cloudwatch_metric_alarm.alb_healthy_host_count.alarm_name
  condition   = var.enable_alb_alarm
}
