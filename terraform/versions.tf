terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # El backend remoto (S3 + DynamoDB) se configura en backend.tf con
  # -backend-config=backend.hcl. El bucket y la tabla los crea bootstrap/.
}
