
variable "aws_region" {
  description = "Infrastructure region"
  type        = string
  default     = "us-east-2"
}

// Variables para el módulo VPC
variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "CIDR blocks para las subredes públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "CIDR blocks para las subredes privadas"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "Zonas de disponibilidad para las subredes"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

#Variables para el módulo EC2
# EC2 configuration
variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
}

variable "instance_type" {
  description = "Instance type for EC2"
  type        = string
  default     = "t3.micro"
}

variable "ec2_instance_count" {
  description = "Number of EC2 instances"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
}



# Auto Scaling configuration
variable "autoscaling_desired_capacity" {
  description = "Desired capacity of Auto Scaling group"
  type        = number
  default     = 2
}

variable "autoscaling_max_size" {
  description = "Maximum size of Auto Scaling group"
  type        = number
  default     = 4
}

variable "autoscaling_min_size" {
  description = "Minimum size of Auto Scaling group"
  type        = number
  default     = 1
}

# S3 bucket configuration
variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

# DynamoDB configuration
variable "dynamodb_table_name" {
  description = "Name of DynamoDB table for state locking"
  type        = string
}

# RDS configuration
variable "rds_engine" {
  description = "Database engine for RDS"
  type        = string
  default     = "mysql"
}

variable "rds_instance_class" {
  description = "Instance class for RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "Allocated storage for RDS"
  type        = number
  default     = 20
}

variable "rds_db_name" {
  description = "Database name for RDS"
  type        = string
}

variable "rds_username" {
  description = "Username for RDS"
  type        = string
}

variable "rds_password" {
  description = "Password for RDS"
  type        = string
  sensitive   = true
}

# CloudWatch configuration
variable "cloudwatch_log_group_name" {
  description = "Log group name for CloudWatch"
  type        = string
}

variable "cloudwatch_retention_in_days" {
  description = "Retention period in days for CloudWatch logs"
  type        = number
  default     = 7
}



variable "subnet_id" {
  description = "ID de la subred donde se lanzará la instancia EC2"
  type        = string
}

variable "security_group_id" {
  description = "ID del grupo de seguridad para las instancias EC2"
  type        = string
}

variable "key_name" {
  description = "Nombre de la clave SSH para acceso a la instancia EC2"
  type        = string
}

// Variables para el módulo Auto Scaling
variable "min_size" {
  description = "Número mínimo de instancias en el grupo de autoescalado"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Número máximo de instancias en el grupo de autoescalado"
  type        = number
  default     = 5
}

variable "desired_capacity" {
  description = "Capacidad deseada del grupo de autoescalado"
  type        = number
  default     = 2
}

variable "subnets" {
  description = "Lista de subnets para el grupo de autoescalado"
  type        = list(string)
}

// Variables para el módulo ALB (Application Load Balancer)
variable "alb_name" {
  description = "Nombre del Application Load Balancer"
  type        = string
  default     = "AppALB"
}

// Variables para el módulo S3
variable "s3_bucket_name" {
  description = "Nombre del bucket de S3 Orbidi"
  type        = string
}

// Variables para el módulo RDS
variable "allocated_storage" {
  description = "Tamaño de almacenamiento en GB para la instancia RDS"
  type        = number
  default     = 20
}

variable "instance_class" {
  description = "Clase de instancia para RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Nombre de la base de datos RDS"
  type        = string
}

variable "db_username" {
  description = "Nombre de usuario para la base de datos RDS"
  type        = string
}

variable "db_password" {
  description = "Contraseña para la base de datos RDS"
  type        = string
  sensitive   = true
}

// Variables para el módulo DynamoDB
variable "table_name" {
  description = "Nombre de la tabla DynamoDB"
  type        = string
  default     = "AppTable"
}

// Variables para el módulo CloudWatch
variable "log_group_name" {
  description = "Nombre del grupo de logs en CloudWatch"
  type        = string
  default     = "/aws/app/logs"
}

variable "retention_in_days" {
  description = "Días de retención de los logs en CloudWatch"
  type        = number
  default     = 7
}

// Variables para el módulo IAM
variable "role_name" {
  description = "Nombre del rol IAM para EC2"
  type        = string
  default     = "AppRole"
}

variable "policy_name" {
  description = "Nombre de la política IAM"
  type        = string
  default     = "AppPolicy"
}
