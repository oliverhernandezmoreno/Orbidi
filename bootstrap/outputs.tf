output "state_bucket_name" {
  description = "Bucket S3 para el estado remoto de Terraform"
  value       = aws_s3_bucket.state.bucket
}

output "state_lock_table_name" {
  description = "Tabla DynamoDB para el bloqueo del estado"
  value       = aws_dynamodb_table.locks.name
}

output "ecr_repository_name" {
  description = "Nombre del repositorio ECR"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR"
  value       = aws_ecr_repository.app.repository_url
}

output "region" {
  description = "Región usada por el bootstrap"
  value       = var.region
}
