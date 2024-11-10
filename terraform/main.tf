provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source            = "./modules/vpc"
  vpc_cidr          = var.vpc_cidr
  public_subnets    = var.public_subnets
  private_subnets   = var.private_subnets
  availability_zones = var.availability_zones
}

module "ec2" {
  source         = "./modules/ec2"
  ami_id         = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  instance_type  = "t3.micro"
  subnet_ids     = module.vpc.public_subnet_ids
  key_name       = var.key_name
}

# Módulo de Auto Scaling: configura un grupo de escalado automático
module "autoscaling" {
  source            = "./modules/autoscaling"
  ami_id            = var.ami_id
  instance_type     = var.instance_type
  key_name          = var.key_name
  desired_capacity  = var.autoscaling_desired_capacity
  max_size          = var.autoscaling_max_size
  min_size          = var.autoscaling_min_size
  subnet_ids        = module.vpc.private_subnet_ids
}

# Módulo de ALB: configura un Application Load Balancer (ALB)
module "alb" {
  source          = "./modules/alb"
  subnet_ids      = module.vpc.public_subnet_ids
  security_groups = [module.vpc.vpc_default_security_group]
}

# Módulo de S3: crea un bucket S3 para almacenamiento
module "s3" {
  source      = "./modules/s3"
  bucket_name = var.s3_bucket_name
}

# Módulo de DynamoDB: crea una tabla DynamoDB para bloqueo de estado de Terraform
module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = var.dynamodb_table_name
}

# Módulo de RDS: configura una base de datos relacional RDS
module "rds" {
  source         = "./modules/rds"
  engine         = var.rds_engine
  instance_class = var.rds_instance_class
  storage        = var.rds_allocated_storage
  db_name        = var.rds_db_name
  username       = var.rds_username
  password       = var.rds_password
  subnet_ids     = module.vpc.private_subnet_ids
  security_group = module.vpc.vpc_default_security_group
}

# Módulo de CloudWatch: configura CloudWatch para monitoreo y alarmas
module "cloudwatch" {
  source           = "./modules/cloudwatch"
  log_group_name   = var.cloudwatch_log_group_name
  retention_in_days = var.cloudwatch_retention_in_days
}

