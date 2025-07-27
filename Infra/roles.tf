// IAM roles for Lambda and Step Function execution
// Defines trust policies and tags for each role

data "aws_caller_identity" "current" {}


resource "aws_iam_role" "LambdaExecutionRole" {
  name = "${var.project_name}-${var.environment}-LambdaExecutionRole"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}



resource "aws_iam_role" "StepFunctionTriggerRole" {
  name = "${var.project_name}-${var.environment}-StepFunctionTriggerRole"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

}

resource "aws_iam_role" "TerraformDeploymentRole" {
  name = "${var.project_name}-${var.environment}-TerraformDeploymentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/TerraformOperatorRole"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role" "TerraformOperatorRole" {
  name = "${var.project_name}-${var.environment}-TerraformOperatorRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Order_fullfillment_project_user"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "operator_assume_attach" {
  role       = aws_iam_role.TerraformOperatorRole.name
  policy_arn = aws_iam_policy.assume_deployment_role.arn
}

