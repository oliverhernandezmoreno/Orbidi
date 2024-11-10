# Alarma de CloudWatch para la utilización de CPU en instancias EC2
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  count               = var.enable_cpu_alarm ? 1 : 0
  alarm_name          = "${var.alarm_name_prefix}-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "Alarma de CloudWatch cuando la CPU sobrepasa el umbral definido"
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  dimensions = {
    InstanceId = var.instance_id
  }
}

# Alarma de CloudWatch para el balanceador de carga (ejemplo)
resource "aws_cloudwatch_metric_alarm" "alb_healthy_host_count" {
  count               = var.enable_alb_alarm ? 1 : 0
  alarm_name          = "${var.alarm_name_prefix}-alb-healthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.evaluation_periods
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = var.alarm_period
  statistic           = "Average"
  threshold           = var.alb_threshold
  alarm_description   = "Alarma de CloudWatch cuando el conteo de hosts saludables cae por debajo del umbral"
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  dimensions = {
    LoadBalancer = var.alb_name
  }
}
