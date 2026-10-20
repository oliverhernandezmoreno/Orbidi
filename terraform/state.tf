# Recursos del estado remoto de Terraform.
#
# NOTA (Fase 1 del PLAN.md): estos recursos se moverán a un directorio
# `bootstrap/` con su propio estado para evitar el problema huevo-gallina.
# Se dejan aquí, sin cambios de address, para no romper el plan actual.

data "aws_caller_identity" "current" {}

locals {
  # Si no se define bucket_name se usa uno único por cuenta.
  state_bucket_name = coalesce(
    var.bucket_name,
    "${var.name}-tfstate-${data.aws_caller_identity.current.account_id}"
  )
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = local.state_bucket_name
}

# Enable versioning so you can see the full revision history of your
# state files
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption by default
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Explicitly block all public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
