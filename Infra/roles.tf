// IAM roles following least-privilege principle
// Separate roles for deployment vs runtime execution to prevent privilege escalation

data "aws_caller_identity" "current" {}

// Trust policy for Terraform deployment (human/CI only)
data "aws_iam_policy_document" "terraform_deployer_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Order_fullfillment_project_user"]
    }
    actions = ["sts:AssumeRole"]
    
    # Optional: Add IP restrictions for enhanced security
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = [
        # "203.0.113.0/24",  # Your office IP range
        # "198.51.100.0/24"  # GitHub Actions IP range (if using self-hosted runners)
      ]
    }
    
    # Optional: Add MFA requirement
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["true"]
    }
  }
}

// Trust policy for Lambda execution (service principal only)
data "aws_iam_policy_document" "lambda_execution_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

// Trust policy for Step Functions execution (service principal only)
data "aws_iam_policy_document" "step_function_execution_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

// Deployment role - assumed only by human/CI for infrastructure management
resource "aws_iam_role" "TerraformDeploymentRole" {
  name = "${var.project_name}-${var.environment}-TerraformDeploymentRole"

  assume_role_policy = data.aws_iam_policy_document.terraform_deployer_trust.json

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

// Lambda execution role - assumed only by Lambda service for runtime operations
resource "aws_iam_role" "LambdaExecutionRole" {
  name = "${var.project_name}-${var.environment}-LambdaExecutionRole"

  assume_role_policy = data.aws_iam_policy_document.lambda_execution_trust.json

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

// Step Functions execution role - assumed only by Step Functions service
resource "aws_iam_role" "StepFunctionExecutionRole" {
  name = "${var.project_name}-${var.environment}-StepFunctionExecutionRole"

  assume_role_policy = data.aws_iam_policy_document.step_function_execution_trust.json

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}



