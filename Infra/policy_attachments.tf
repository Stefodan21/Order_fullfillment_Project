// Policy attachments following least-privilege principle
// Separate roles for deployment vs runtime execution to prevent privilege escalation

// Deployment role - only for infrastructure provisioning (human/CI access)
resource "aws_iam_role_policy_attachment" "terraform_infrastructure_provisioning" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.terraform_infrastructure_provisioning.arn
}

// Lambda execution role - minimal runtime permissions only
resource "aws_iam_role_policy_attachment" "lambda_runtime_execution" {
  role       = aws_iam_role.LambdaExecutionRole.name
  policy_arn = aws_iam_policy.lambda_runtime_execution.arn
}

// Step Functions execution role - minimal orchestration permissions only
resource "aws_iam_role_policy_attachment" "step_function_runtime_execution" {
  role       = aws_iam_role.StepFunctionExecutionRole.name
  policy_arn = aws_iam_policy.step_function_runtime_execution.arn
}

// Total: 3 policies across 3 roles (all under AWS 10-policy limit)
// Security: No privilege escalation possible - runtime services cannot access deployment permissions
