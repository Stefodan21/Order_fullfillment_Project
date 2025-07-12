// Role for core Lambda functions (validation, invoice, shipping, tracking)
resource "aws_iam_role" "LambdaExecutionRole" {
  name = "Order_fullfillment_project_user_LambdaExecutionRole"

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
  name = "Order_fullfillment_project_user_StepFunctionTriggerRole"

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
