variable "github_repo" {
  description = "Repositorio de GitHub autorizado a asumir el rol (owner/repo)"
  type        = string
  default     = "oliverhernandezmoreno/Orbidi"
}

variable "app_name" {
  description = "Prefijo de los roles creados por el root module principal"
  type        = string
  default     = "app-3"
}

variable "create_oidc_provider" {
  description = "Crear el provider OIDC de GitHub. Poner false si ya existe en la cuenta."
  type        = bool
  default     = true
}

variable "oidc_provider_arn" {
  description = "ARN del provider OIDC existente cuando create_oidc_provider = false"
  type        = string
  default     = ""
}
