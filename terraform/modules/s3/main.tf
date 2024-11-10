# Creación del bucket S3
resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name
  acl    = var.bucket_acl

  # Configuración de versionado (si está habilitado)
  versioning {
    enabled = var.enable_versioning
  }

  # Configuración de etiquetas para el bucket
  tags = var.tags
}

# Política de cifrado del bucket S3
resource "aws_s3_bucket_server_side_encryption_configuration" "app_bucket_encryption" {
  bucket = aws_s3_bucket.app_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

# Política del bucket S3 (opcional)
resource "aws_s3_bucket_policy" "app_bucket_policy" {
  bucket = aws_s3_bucket.app_bucket.id
  policy = var.bucket_policy != "" ? var.bucket_policy : null
  count  = var.bucket_policy != "" ? 1 : 0
}
