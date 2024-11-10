# Identificador de la instancia de EC2
variable "instance_id" {
  description = "ID de la instancia EC2 para la alarma de CPU"
  type        = string
}

# Umbral de CPU para activar la alarma
variable "cpu_threshold" {
  description = "Umbral de CPU para la alarma"
  type        = number
  default     = 80
}

# Activar alarma de CPU
variable "enable_cpu_alarm" {
  description = "Activar alarma de CloudWatch para la utilización de CPU"
  type        = bool
  default     = true
}

# Nombre del balanceador de carga (ALB)
variable "alb_name" {
  description = "Nombre del balanceador de carga para la alarma de hosts saludables"
  type        = string
  default     = ""
}

# Umbral de hosts saludables para el ALB
variable "alb_threshold" {
  description = "Umbral de conteo de hosts saludables para el ALB"
  type        = number
  default     = 1
}

# Activar alarma para ALB
variable "enable_alb_alarm" {
  description = "Activar alarma de CloudWatch para el ALB"
  type        = bool
  default     = false
}

# Prefijo del nombre para las alarmas
variable "alarm_name_prefix" {
  description = "Prefijo para los nombres de las alarmas"
  type        = string
  default     = "app"
}

# Período de tiempo en segundos para la métrica de CloudWatch
variable "alarm_period" {
  description = "Período de tiempo en segundos para las métricas de CloudWatch"
  type        = number
  default     = 300
}

# Períodos de evaluación necesarios para activar la alarma
variable "evaluation_periods" {
  description = "Número de períodos de evaluación para activar la alarma"
  type        = number
  default     = 2
}

# Acciones a ejecutar cuando la alarma está activa
variable "alarm_actions" {
  description = "Acciones de SNS u otros recursos a ejecutar cuando la alarma esté activa"
  type        = list(string)
  default     = []
}

# Acciones a ejecutar cuando la alarma vuelva al estado OK
variable "ok_actions" {
  description = "Acciones de SNS u otros recursos a ejecutar cuando la alarma esté en estado OK"
  type        = list(string)
  default     = []
}
