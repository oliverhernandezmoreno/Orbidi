# Nombre de la tabla DynamoDB
output "table_name" {
  description = "Nombre de la tabla DynamoDB"
  value       = aws_dynamodb_table.app_table.name
}

# ARN de la tabla DynamoDB
output "table_arn" {
  description = "ARN de la tabla DynamoDB"
  value       = aws_dynamodb_table.app_table.arn
}

# Estado de los índices globales secundarios
output "global_secondary_indexes" {
  description = "Lista de índices globales secundarios creados en la tabla DynamoDB"
  value       = aws_dynamodb_table.app_table
}
# Nombre del bucket S3
output "bucket_name" {
  description = "Nombre del bucket S3"
  value       = aws_s3_bucket.app_bucket.bucket
}

# ARN del bucket S3
output "bucket_arn" {
  description = "ARN del bucket S3"
  value       = aws_s3_bucket.app_bucket.arn
}

# URL del bucket S3
output "bucket_url" {
  description = "URL del bucket S3"
  value       = "" #aws_s3_bucket.app_bucket.website_endpoint
}

# Estado del versionado del bucket S3
output "versioning_status" {
  description = "Estado del versionado del bucket S3"
  value       = aws_s3_bucket.app_bucket.versioning.0.enabled
}
