# -------------------------
# Red
# -------------------------
output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs de las subredes públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs de las subredes privadas"
  value       = aws_subnet.private[*].id
}

# -------------------------
# Aplicación
# -------------------------
output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = aws_lb.front.dns_name
}

output "ecs_cluster_name" {
  description = "Nombre del cluster ECS"
  value       = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  description = "Nombre del servicio ECS"
  value       = aws_ecs_service.app.name
}

output "log_group_name" {
  description = "Log group de la aplicación"
  value       = aws_cloudwatch_log_group.app.name
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR usado por la tarea"
  value       = data.aws_ecr_repository.app.repository_url
}

# -------------------------
# DynamoDB
# -------------------------
output "table_name" {
  description = "Nombre de la tabla DynamoDB de la aplicación"
  value       = aws_dynamodb_table.app_table.name
}

output "table_arn" {
  description = "ARN de la tabla DynamoDB de la aplicación"
  value       = aws_dynamodb_table.app_table.arn
}

output "global_secondary_indexes" {
  description = "Índices globales secundarios de la tabla"
  value       = aws_dynamodb_table.app_table.global_secondary_index
}
