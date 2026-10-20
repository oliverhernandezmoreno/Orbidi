# -------------------------
# General
# -------------------------
variable "region" {
  description = "Infrastructure region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Perfil de la AWS CLI a usar. Null usa la cadena de credenciales por defecto."
  type        = string
  default     = null
}

variable "name" {
  description = "Nombre base de la aplicación y de sus recursos"
  type        = string
  default     = "app-3"
}

# -------------------------
# Red
# -------------------------
variable "vpc_cidr" {
  description = "CIDR de la VPC"
  type        = string
  default     = "10.20.30.0/24"
}

variable "subnet_cidr_private" {
  description = "CIDR de las subredes privadas"
  type        = list(string)
  default     = ["10.20.30.0/27", "10.20.30.32/27", "10.20.30.64/27"]
}

variable "subnet_cidr_public" {
  description = "CIDR de las subredes públicas"
  type        = list(string)
  default     = ["10.20.30.96/27", "10.20.30.128/27", "10.20.30.160/27"]
}

# -------------------------
# Contenedor / ECS
# -------------------------
variable "ecr_repository_name" {
  description = "Repositorio ECR creado por bootstrap/"
  type        = string
  default     = "orbidi/api"
}

variable "image_tag" {
  description = "Tag de la imagen a desplegar"
  type        = string
  default     = "latest"
}

variable "container_port" {
  description = "Puerto que expone el contenedor"
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "CPU de la tarea Fargate (unidades de 1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Memoria de la tarea Fargate en MiB"
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Número inicial de tareas"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "Mínimo de tareas para el auto scaling"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "Máximo de tareas para el auto scaling"
  type        = number
  default     = 6
}

variable "log_retention_days" {
  description = "Retención de logs en CloudWatch"
  type        = number
  default     = 14
}

# -------------------------
# Alarmas
# -------------------------
variable "cpu_threshold" {
  description = "Umbral de CPU para alarmas y target tracking"
  type        = number
  default     = 70
}

variable "alarm_period" {
  description = "Período de las métricas de CloudWatch en segundos"
  type        = number
  default     = 300
}

variable "evaluation_periods" {
  description = "Períodos de evaluación para activar una alarma"
  type        = number
  default     = 2
}

variable "alarm_actions" {
  description = "ARNs (por ejemplo SNS) a notificar cuando la alarma se activa"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "ARNs a notificar cuando la alarma vuelve a OK"
  type        = list(string)
  default     = []
}

# -------------------------
# DynamoDB
# -------------------------
variable "table_name" {
  description = "Nombre de la tabla DynamoDB de la aplicación"
  type        = string
  default     = "orbidi-app"
}

variable "hash_key" {
  description = "Clave de partición (hash) de la tabla"
  type        = string
  default     = "id"
}

variable "hash_key_type" {
  description = "Tipo de la clave de partición (S, N o B)"
  type        = string
  default     = "S"
}

variable "range_key" {
  description = "Clave de ordenación (rango) opcional"
  type        = string
  default     = ""
}

variable "range_key_type" {
  description = "Tipo de la clave de ordenación (S, N o B)"
  type        = string
  default     = "S"
}

variable "billing_mode" {
  description = "Modo de facturación: PAY_PER_REQUEST o PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Capacidad de lectura si billing_mode es PROVISIONED"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Capacidad de escritura si billing_mode es PROVISIONED"
  type        = number
  default     = 5
}

variable "global_secondary_indexes" {
  description = "Configuración de índices globales secundarios"
  type = list(object({
    name               = string
    hash_key           = string
    range_key          = optional(string)
    read_capacity      = optional(number)
    write_capacity     = optional(number)
    projection_type    = string
    non_key_attributes = optional(list(string))
  }))
  default = []
}
