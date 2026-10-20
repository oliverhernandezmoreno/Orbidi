terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # El backend remoto (S3 + DynamoDB) se habilita en la Fase 1 del PLAN.md.
  # Hasta entonces el estado es local para no bloquear el bootstrap.
}
