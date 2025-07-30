// Policy attachments following least-privilege principle
// Separate roles for deployment vs runtime execution to prevent privilege escalation

locals {
  # Map of role-policy attachments for consistent lifecycle management
  policy_attachments = {
    terraform_infrastructure = {
      role        = aws_iam_role.TerraformDeploymentRole.name
      policy_arn  = aws_iam_policy.terraform_infrastructure_provisioning.arn
      description = "Deployment role - infrastructure provisioning (human/CI access)"
    }
    lambda_runtime = {
      role        = aws_iam_role.LambdaExecutionRole.name
      policy_arn  = aws_iam_policy.lambda_runtime_execution.arn
      description = "Lambda execution role - minimal runtime permissions only"
    }
    step_function_runtime = {
      role        = aws_iam_role.StepFunctionExecutionRole.name
      policy_arn  = aws_iam_policy.step_function_runtime_execution.arn
      description = "Step Functions execution role - minimal orchestration permissions only"
    }
  }

  # Group policy attachments for bootstrap access
  group_policy_attachments = {
    bootstrap_group_infrastructure = {
      group       = var.iam_group
      policy_arn  = aws_iam_policy.terraform_infrastructure_provisioning.arn
      description = "Bootstrap group - infrastructure provisioning permissions"
    }
  }

  # User policy attachments for direct access
  user_policy_attachments = {
    bootstrap_user_infrastructure = {
      user        = var.iam_user
      policy_arn  = aws_iam_policy.terraform_infrastructure_provisioning.arn
      description = "Bootstrap user - direct infrastructure provisioning permissions"
    }
  }
}

// Consolidated policy attachments using for_each
resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each = local.policy_attachments

  role       = each.value.role
  policy_arn = each.value.policy_arn

  # Consistent lifecycle management for all attachments
  lifecycle {
    create_before_destroy = true
  }
}

// Group policy attachments for bootstrap access
resource "aws_iam_group_policy_attachment" "group_policy_attachments" {
  for_each = local.group_policy_attachments

  group      = each.value.group
  policy_arn = each.value.policy_arn

  # Consistent lifecycle management for all attachments
  lifecycle {
    create_before_destroy = true
  }
}

// User policy attachments for direct access
resource "aws_iam_user_policy_attachment" "user_policy_attachments" {
  for_each = local.user_policy_attachments

  user       = each.value.user
  policy_arn = each.value.policy_arn

  # Consistent lifecycle management for all attachments
  lifecycle {
    create_before_destroy = true
  }
}

// Total: 3 policies across 3 roles + 1 group policy + 1 user policy (all under AWS limits)
// Security: No privilege escalation possible - runtime services cannot access deployment permissions
