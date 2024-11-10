# Nombre del bucket S3
variable "bucket_name" {
  description = "Nombre del bucket S3"
  type        = string
}

# ACL del bucket S3
variable "bucket_acl" {
  description = "Control de acceso para el bucket S3"
  type        = string
  default     = "private"
}

# Activar versionado en el bucket
variable "enable_versioning" {
  description = "Activar versionado en el bucket S3"
  type        = bool
  default     = false
}

# Política opcional para el bucket S3
variable "bucket_policy" {
  description = "Política JSON opcional para el bucket S3"
  type        = string
  default     = ""
}

# Etiquetas para el bucket
variable "tags" {
  description = "Etiquetas aplicadas al bucket S3"
  type        = map(string)
  default     = {}
}
