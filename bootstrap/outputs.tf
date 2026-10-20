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

output "github_actions_role_arn" {
  description = "ARN del rol a configurar en la variable AWS_ROLE_ARN de GitHub"
  value       = aws_iam_role.github_actions.arn
}

output "oidc_provider_arn" {
  description = "ARN del provider OIDC de GitHub"
  value       = local.oidc_provider_arn
}
