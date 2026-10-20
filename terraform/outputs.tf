# -------------------------
# DynamoDB (aplicación)
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
  description = "Índices globales secundarios creados en la tabla DynamoDB"
  value       = aws_dynamodb_table.app_table.global_secondary_index
}

# -------------------------
# Estado remoto de Terraform
# -------------------------
output "state_bucket_name" {
  description = "Bucket S3 que almacena el estado de Terraform"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN del bucket S3 de estado"
  value       = aws_s3_bucket.terraform_state.arn
}

output "state_lock_table_name" {
  description = "Tabla DynamoDB usada para el bloqueo del estado"
  value       = aws_dynamodb_table.terraform_locks.name
}

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
# Cómputo y balanceo
# -------------------------
output "alb_dns_name" {
  description = "DNS público del Application Load Balancer"
  value       = aws_lb.front.dns_name
}

output "autoscaling_group_name" {
  description = "Nombre del Auto Scaling Group de la aplicación"
  value       = aws_autoscaling_group.application.name
}
