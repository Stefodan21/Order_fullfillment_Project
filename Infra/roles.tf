// IAM roles for consolidated deployment and runtime execution
// Single role approach for simplified permission management

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "terraform_deployer_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/Order_fullfillment_project_user"]
    }
    actions = ["sts:AssumeRole"]
  }
  
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com",
        "states.amazonaws.com"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

// Consolidated role for both Terraform deployment and runtime execution
// This role can be assumed by the deployment user and AWS services (Lambda, Step Functions)
resource "aws_iam_role" "TerraformDeploymentRole" {
  name = "${var.project_name}-${var.environment}-TerraformDeploymentRole"

  assume_role_policy = data.aws_iam_policy_document.terraform_deployer_trust.json

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}



