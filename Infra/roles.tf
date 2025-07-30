// IAM roles following least-privilege principle
// Separate roles for deployment vs runtime execution to prevent privilege escalation

data "aws_caller_identity" "current" {}

// Trust policy for Terraform deployment (human/CI only)
data "aws_iam_policy_document" "terraform_deployer_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [var.deployer_principal_arn]
    }
    actions = ["sts:AssumeRole"]
    
    # Optional security conditions - commented out for GitHub secrets workflow
    # Uncomment and configure variables if you want to add IP/MFA restrictions
    
    # # IP restrictions - only applies when allowed_ip_ranges is not empty
    # dynamic "condition" {
    #   for_each = length(var.allowed_ip_ranges) > 0 ? [1] : []
    #   content {
    #     test     = "IpAddress"
    #     variable = "aws:SourceIp"
    #     values   = var.allowed_ip_ranges
    #   }
    # }
    
    # # MFA requirement - only applies when require_mfa is true
    # dynamic "condition" {
    #   for_each = var.require_mfa ? [1] : []
    #   content {
    #     test     = "Bool"
    #     variable = "aws:MultiFactorAuthPresent"
    #     values   = ["true"]
    #   }
    # }
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
    
    # Security conditions to prevent cross-account access and confused-deputy attacks
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    
    # Additional restriction to specific Lambda functions only
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:lambda:us-east-1:${data.aws_caller_identity.current.account_id}:function:${var.project_name}-${var.environment}-*"]
    }
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
    
    # Security conditions to prevent cross-account access
    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:states:us-east-1:${data.aws_caller_identity.current.account_id}:stateMachine:*"]
    }
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



