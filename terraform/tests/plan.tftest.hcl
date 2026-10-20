mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_ecr_repository" {
    defaults = {
      repository_url = "123456789012.dkr.ecr.us-east-1.amazonaws.com/orbidi/api"
    }
  }

  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1a", "us-east-1b", "us-east-1c"]
    }
  }

  mock_data "aws_elb_service_account" {
    defaults = {
      arn = "arn:aws:iam::127311923021:root"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "plan_principal" {
  command = plan

  assert {
    condition     = length(aws_subnet.public) == 3 && length(aws_subnet.private) == 3
    error_message = "Se esperan 3 subredes públicas y 3 privadas."
  }

  assert {
    condition     = aws_ecs_service.app.launch_type == "FARGATE"
    error_message = "El servicio debe ejecutarse en Fargate."
  }

  assert {
    condition     = aws_dynamodb_table.app_table.point_in_time_recovery[0].enabled
    error_message = "PITR debe estar habilitado en DynamoDB."
  }

  assert {
    condition     = aws_lb.front.access_logs[0].enabled
    error_message = "El ALB debe tener access logs habilitados."
  }

  assert {
    condition     = aws_lb_listener.front_end.default_action[0].type == "forward"
    error_message = "Sin certificado, el listener HTTP debe reenviar al target group."
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.ecs_cpu_high.dimensions) > 0
    error_message = "La alarma de CPU debe tener dimensiones."
  }
}

run "https_habilitado" {
  command = plan

  variables {
    certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/test"
  }

  assert {
    condition     = length(aws_lb_listener.https) == 1
    error_message = "Con certificate_arn debe crearse el listener 443."
  }

  assert {
    condition     = aws_lb_listener.front_end.default_action[0].type == "redirect"
    error_message = "Con HTTPS, el listener HTTP debe redirigir."
  }

  assert {
    condition     = length(aws_security_group_rule.alb_ingress_https) == 1
    error_message = "Con HTTPS debe abrirse el puerto 443 en el ALB."
  }
}

run "tag_de_imagen" {
  command = plan

  variables {
    image_tag = "deadbeef"
  }

  assert {
    condition     = can(regex("deadbeef", aws_ecs_task_definition.app.container_definitions))
    error_message = "El tag de imagen debe propagarse a la task definition."
  }
}
