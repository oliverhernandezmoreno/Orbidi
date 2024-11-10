# Creación del Application Load Balancer (ALB)
resource "aws_lb" "app_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_groups
  subnets            = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
}

# Listener para HTTP (si está habilitado)
resource "aws_lb_listener" "http_listener" {
  count    = var.enable_http ? 1 : 0
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

# Listener para HTTPS (si está habilitado)
resource "aws_lb_listener" "https_listener" {
  count = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}

# Grupo de destino para las instancias detrás del ALB
resource "aws_lb_target_group" "app_target_group" {
  name        = "${var.alb_name}-tg"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = var.health_check_timeout
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
  }
}

# Registro de instancias en el grupo de destino
resource "aws_lb_target_group_attachment" "app_target_attachment" {
  for_each          = toset(var.target_instance_ids)
  target_group_arn  = aws_lb_target_group.app_target_group.arn
  target_id         = each.value
  port              = var.target_group_port
}
