// main.tf - Módulo VPC

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet 1" "public" {
  count                  = length(var.public_subnets)
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.public_subnets[count.index]
  availability_zone      = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

resource "aws_subnet 2" "private" {
  count                  = length(var.private_subnets)
  vpc_id                 = aws_vpc.main.id
  cidr_block             = var.private_subnets[count.index]
  availability_zone      = element(var.availability_zones, count.index)
  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_instance 1" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name = "AppInstance 1"
  }
}

resource "aws_instance 2" "app" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name = "AppInstance 2"
  }
}


resource "aws_launch_configuration" "app 1" {
  image_id        = var.ami_id
  instance_type   = var.instance_type
  key_name        = var.key_name
  security_groups = [var.security_group_id]
}

resource "aws_autoscaling_group" "app 2" {
  vpc_zone_identifier = var.subnets
  launch_configuration = aws_launch_configuration.app.id
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
}

resource "aws_lb" "app 1" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnets

  tags = {
    Name = "AppALB"
  }
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "AppTargetGroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = var.bucket_name
  acl    = "private"
}

resource "aws_db_instance" "app_db" {
  allocated_storage    = var.allocated_storage
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = var.instance_class
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  vpc_security_group_ids = [var.security_group_id]
  skip_final_snapshot  = true
}

resource "aws_dynamodb_table" "app_table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPUAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors high CPU usage"
}