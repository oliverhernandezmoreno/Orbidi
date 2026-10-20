variable "region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Perfil de la AWS CLI. Null usa la cadena de credenciales por defecto."
  type        = string
  default     = null
}

variable "project" {
  description = "Prefijo usado para nombrar los recursos compartidos"
  type        = string
  default     = "orbidi"
}

variable "bucket_name" {
  description = "Nombre del bucket de estado. Null genera <project>-tfstate-<account_id>."
  type        = string
  default     = null
}

variable "lock_table_name" {
  description = "Tabla DynamoDB para el bloqueo del estado"
  type        = string
  default     = "orbidi-terraform-locks"
}

variable "ecr_repository_name" {
  description = "Repositorio ECR de la aplicación"
  type        = string
  default     = "orbidi/api"
}
