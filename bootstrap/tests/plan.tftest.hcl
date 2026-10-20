mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "bootstrap_plan" {
  command = plan

  assert {
    condition     = aws_s3_bucket.state.bucket == "orbidi-tfstate-123456789012"
    error_message = "El bucket de estado debe seguir la convención orbidi-tfstate-<account>."
  }

  assert {
    condition     = aws_ecr_repository.app.image_tag_mutability == "IMMUTABLE"
    error_message = "ECR debe usar tags inmutables."
  }

  assert {
    condition     = length(aws_iam_openid_connect_provider.github) == 1
    error_message = "Debe crearse el provider OIDC de GitHub."
  }

  assert {
    condition     = aws_dynamodb_table.locks.point_in_time_recovery[0].enabled
    error_message = "La tabla de locks debe tener PITR."
  }
}
