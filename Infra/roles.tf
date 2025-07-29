// IAM roles for Lambda and Step Function execution
// Defines trust policies and tags for each role

data "aws_caller_identity" "current" {}


resource "aws_iam_role" "LambdaExecutionRole" {
  name = "${var.project_name}-${var.environment}-LambdaExecutionRole-${random_id.bucket_suffix.hex}"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = [
          "lambda.amazonaws.com",
          "states.amazonaws.com"
        ]
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
        Service = [
          "lambda.amazonaws.com",
          "states.amazonaws.com"
        ]
      },
      Action = "sts:AssumeRole"
    }]
  })

}

data "aws_iam_policy_document" "terraform_deployer_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Order_fullfillment_project_user"]
    }
    actions = ["sts:AssumeRole"]
  }
}

// Use a separate policy document for the TerraformDeploymentRole's assume_role_policy to clearly define and manage trust relationships, especially for deployment users.
resource "aws_iam_role" "TerraformDeploymentRole" {
  name = "${var.project_name}-${var.environment}-TerraformDeploymentRole"

  assume_role_policy = data.aws_iam_policy_document.terraform_deployer_trust.json

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}



