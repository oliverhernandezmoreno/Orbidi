provider "aws" {
  region = var.region
  features {
  key_vault {
    purge_soft_delete_on_destroy = true
    }
  }
}