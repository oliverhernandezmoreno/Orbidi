# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "${var.name}-default-sg"
  }
}

# ------------------------------------------------------------------
# Security group del ALB
# ------------------------------------------------------------------
resource "aws_security_group" "alb" {
  name        = "${var.name}-alb-sg"
  description = "Permite HTTP desde internet hacia el Application Load Balancer"
  vpc_id      = aws_vpc.this.id

  tags = {
    "Name" = "${var.name}-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_ingress_http" {
  description       = "HTTP desde internet"
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_ingress_https" {
  count = local.https_enabled ? 1 : 0

  description       = "HTTPS desde internet"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "alb_egress_ecs" {
  description              = "Trafico hacia las tareas ECS"
  type                     = "egress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_service.id
  security_group_id        = aws_security_group.alb.id
}

# ------------------------------------------------------------------
# Security group de las tareas ECS
# ------------------------------------------------------------------
resource "aws_security_group" "ecs_service" {
  name        = "${var.name}-ecs-sg"
  description = "Permite trafico desde el ALB y salida a ECR/CloudWatch"
  vpc_id      = aws_vpc.this.id

  tags = {
    "Name" = "${var.name}-ecs-sg"
  }
}

resource "aws_security_group_rule" "ecs_ingress_alb" {
  description              = "Trafico desde el ALB"
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ecs_service.id
}

resource "aws_security_group_rule" "ecs_egress_https" {
  description       = "Salida HTTPS a ECR, CloudWatch y APIs de AWS"
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service.id
}

resource "aws_security_group_rule" "ecs_egress_dns_udp" {
  description       = "Resolucion DNS"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service.id
}

resource "aws_security_group_rule" "ecs_egress_dns_tcp" {
  description       = "Resolucion DNS"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_service.id
}
