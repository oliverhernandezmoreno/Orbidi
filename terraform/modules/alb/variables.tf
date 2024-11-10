# Subnet IDs en las que se desplegará el ALB
variable "subnet_ids" {
  description = "Lista de IDs de subredes donde el ALB será desplegado"
  type        = list(string)
}

# Security Groups para el ALB
variable "security_groups" {
  description = "Lista de IDs de grupos de seguridad que se asociarán al ALB"
  type        = list(string)
}

# Nombre del ALB
variable "alb_name" {
  description = "Nombre del Application Load Balancer"
  type        = string
  default     = "app-load-balancer"
}

# Habilitar o deshabilitar el acceso HTTP
variable "enable_http" {
  description = "Habilitar el acceso HTTP en el ALB (puerto 80)"
  type        = bool
  default     = false
}

# Habilitar o deshabilitar el acceso HTTPS
variable "enable_https" {
  description = "Habilitar el acceso HTTPS en el ALB (puerto 443)"
  type        = bool
  default     = true
}

# ARN del certificado SSL para HTTPS
variable "ssl_certificate_arn" {
  description = "ARN del certificado SSL para habilitar HTTPS en el ALB"
  type        = string
  default     = ""
}

# Activar o desactivar la protección contra eliminación
variable "enable_deletion_protection" {
  description = "Activar la protección contra eliminación del ALB"
  type        = bool
  default     = true
}

# Puerto y protocolo para el grupo de destino
variable "target_group_port" {
  description = "Puerto en el que el grupo de destino escucha el tráfico"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocolo del grupo de destino"
  type        = string
  default     = "HTTP"
}

# ID de la VPC donde se desplegará el ALB
variable "vpc_id" {
  description = "ID de la VPC donde el ALB y el grupo de destino serán desplegados"
  type        = string
}

# Lista de IDs de instancias para registrar en el grupo de destino
variable "target_instance_ids" {
  description = "Lista de IDs de instancias que se registrarán en el grupo de destino del ALB"
  type        = list(string)
  default     = []
}

# Configuración de chequeo de salud
variable "health_check_path" {
  description = "Ruta para el chequeo de salud en el ALB"
  type        = string
  default     = "/health"
}

variable "health_check_interval" {
  description = "Intervalo de tiempo (en segundos) entre chequeos de salud"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Tiempo de espera para el chequeo de salud"
  type        = number
  default     = 5
}

variable "healthy_threshold" {
  description = "Número de chequeos exitosos para marcar el recurso como saludable"
  type        = number
  default     = 2
}

variable "unhealthy_threshold" {
  description = "Número de chequeos fallidos para marcar el recurso como no saludable"
  type        = number
  default     = 2
}
