# ARN del ALB
output "alb_arn" {
  description = "ARN del Application Load Balancer"
  value       = aws_lb.app_alb.arn
}

# Nombre del ALB
output "alb_name" {
  description = "Nombre del Application Load Balancer Orbidi"
  value       = aws_lb.app_alb.name
}

# Dirección DNS del ALB
output "alb_dns_name" {
  description = "Nombre DNS del Application Load Balancer Orbidi"
  value       = aws_lb.app_alb.dns_name
}

# Hosted Zone ID del ALB, útil para configurar Route 53
output "alb_hosted_zone_id" {
  description = "Hosted Zone ID del Application Load Balancer Orbidi"
  value       = aws_lb.app_alb.hosted_zone_id
}

# ARN del listener de HTTP, si está habilitado
output "http_listener_arn" {
  description = "ARN del listener HTTP en el Application Load Balancer Orbidi"
  value       = aws_lb_listener.http_listener.arn
  condition   = var.enable_http
}

# ARN del listener de HTTPS, si está habilitado
output "https_listener_arn" {
  description = "ARN del listener HTTPS en el Application Load Balancer Orbidi"
  value       = aws_lb_listener.https_listener.arn
  condition   = var.enable_https
}

# Estado de salud del grupo de destino
output "target_group_health_status" {
  description = "Estado de salud del grupo de destino Orbidi"
  value       = aws_lb_target_group.app_target_group.health_check_path
}
