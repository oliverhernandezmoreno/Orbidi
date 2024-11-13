#Define AWS Region
variable "region" {
  description = "Infrastructure region"
  type        = string
  default     = "us-east-1"
}
#Define IAM User Access Key
variable "access_key" {
  description = "The access_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  #default     = ""
}
#Define IAM User Secret Key
variable "secret_key" {
  description = "The secret_key that belongs to the IAM user"
  type        = string
  sensitive   = true
  #default     = ""
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


# Nombre del bucket S3
variable "bucket_name" {
  description = "orbidi-bucket"
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
# Etiquetas para el bucket
variable "tags" {
  description = "Etiquetas aplicadas al bucket S3"
  type        = map(string)
  default     = {}
}

# Clave de partición (hash) de la tabla
variable "hash_key" {
  description = "Clave de partición (hash) de la tabla"
  type        = string
}

# Tipo de dato de la clave de partición (S para String, N para Number, B para Binary)
variable "hash_key_type" {
  description = "Tipo de dato de la clave de partición (hash)"
  type        = string
  default     = "S"
}

# Clave de ordenación (rango) de la tabla (opcional)
variable "range_key" {
  description = "Clave de ordenación (rango) de la tabla"
  type        = string
  default     = ""
}

# Tipo de dato de la clave de ordenación (rango) (S para String, N para Number, B para Binary)
variable "range_key_type" {
  description = "Tipo de dato de la clave de ordenación (rango)"
  type        = string
  default     = "S"
}

# Modo de facturación: PAY_PER_REQUEST o PROVISIONED
variable "billing_mode" {
  description = "Modo de facturación: PAY_PER_REQUEST o PROVISIONED"
  type        = string
  default     = "PAY_PER_REQUEST"
}

# Capacidad de lectura (solo aplicable si billing_mode es PROVISIONED)
variable "read_capacity" {
  description = "Capacidad de lectura para la tabla DynamoDB (si billing_mode es PROVISIONED)"
  type        = number
  default     = 5
}

# Capacidad de escritura (solo aplicable si billing_mode es PROVISIONED)
variable "write_capacity" {
  description = "Capacidad de escritura para la tabla DynamoDB (si billing_mode es PROVISIONED)"
  type        = number
  default     = 5
}

# Configuración de índices globales secundarios (opcional)
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

variable "table_name" {
  description = "Name of DynamoDB table for state locking"
  type        = string
}
