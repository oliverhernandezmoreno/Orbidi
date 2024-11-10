# ARN del grupo de Auto Scaling
output "asg_arn" {
  description = "ARN del grupo de Auto Scaling Orbidi"
  value       = aws_autoscaling_group.app_asg.arn
}

# Nombre del grupo de Auto Scaling
output "asg_name" {
  description = "Nombre del grupo de Auto Scaling Orbidi"
  value       = aws_autoscaling_group.app_asg.name
}

# Lista de IDs de las instancias en el grupo de Auto Scaling
output "instance_ids" {
  description = "Lista de IDs de instancias asociadas al grupo de Auto Scaling Orbidi"
  value       = aws_autoscaling_group.app_asg.instances
}

# Min, Max y Desired capacity para referencia
output "asg_desired_capacity" {
  description = "Capacidad deseada del grupo de Auto Scaling Orbidi"
  value       = aws_autoscaling_group.app_asg.desired_capacity
}

output "asg_max_size" {
  description = "Tamaño máximo del grupo de Auto Scaling Orbidi"
  value       = aws_autoscaling_group.app_asg.max_size
}

output "asg_min_size" {
  description = "Tamaño mínimo del grupo de Auto Scaling Orbidi"
  value       = aws_autoscaling_group.app_asg.min_size
}
