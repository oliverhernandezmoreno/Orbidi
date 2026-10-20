terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Bootstrap con estado LOCAL a propósito: crea el backend remoto que
  # usará el resto de la infraestructura. Aplicar una sola vez.
}
