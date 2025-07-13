// IAM roles for Lambda and Step Function execution
// Defines trust policies and tags for each role
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
