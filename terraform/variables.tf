#Define AWS Region
variable "region" {
  description = "Infrastructure region"
  type        = string
  default     = "us-east-2"
}
#Define IAM User Access Key
variable "access_key" {
  description = "The access_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  default     = ""
}
#Define IAM User Secret Key
variable "secret_key" {
  description = "The secret_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  default     = ""
}
variable "vpc_cidr" {
  description = "the vpc cidr"
  default     = "10.20.30.0/24"
}
variable "subnet_cidr_private" {
  description = "cidr blocks for the private subnets"
  default     = ["10.20.30.0/27", "10.20.30.32/27", "10.20.30.64/27"]
  type        = list(any)
}
variable "subnet_cidr_public" {
  description = "cidr blocks for the public subnets"
  default     = ["10.20.30.96/27", "10.20.30.128/27", "10.20.30.160/27"]
  type        = list(any)
}
variable "ami_name" {
  description = "The ami name of the image from where the instances will be created"
  default     = ["amzn2-ami-amd-hvm-2.0.20230727.0-x86_64-gp2"]
  type        = list(string)
}
variable "instance_type" {
  description = "The instance type of the EC2 instances"
  default     = "t2.medium"
  type        = string
}
variable "name" {
  description = "The name of the application."
  type        = string
  default     = "app-3"
}

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
# ARN de la alarma de CPU
output "cpu_utilization_alarm_arn" {
  description = "ARN de la alarma de CloudWatch para la utilización de CPU"
  value       = aws_cloudwatch_metric_alarm.cpu_utilization_alarm.arn
  #condition   = var.enable_cpu_alarm
}

# Nombre de la alarma de CPU
output "cpu_utilization_alarm_name" {
  description = "Nombre de la alarma de CloudWatch para la utilización de CPU"
  value       = aws_cloudwatch_metric_alarm.cpu_utilization_alarm.alarm_name
#  condition   = var.enable_cpu_alarm
}

# ARN de la alarma de ALB
output "alb_healthy_host_count_alarm_arn" {
  description = "ARN de la alarma de CloudWatch para el conteo de hosts saludables en el ALB"
  value       = aws_cloudwatch_metric_alarm.alb_healthy_host_count.arn
 # condition   = var.enable_alb_alarm
}

# Nombre de la alarma de ALB
output "alb_healthy_host_count_alarm_name" {
  description = "Nombre de la alarma de CloudWatch para el conteo de hosts saludables en el ALB"
  value       = aws_cloudwatch_metric_alarm.alb_healthy_host_count.alarm_name
  #condition   = var.enable_alb_alarm
}
