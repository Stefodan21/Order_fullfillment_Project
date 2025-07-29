// Policy attachments for TerraformDeploymentRole
// Attaches all necessary Terraform provisioning policies to enable full resource lifecycle management

resource "aws_iam_role_policy_attachment" "terraform_kms_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.terraform_kms_provision.arn
}

resource "aws_iam_role_policy_attachment" "terraform_apigateway_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.terraform_apigateway_provision.arn
}

resource "aws_iam_role_policy_attachment" "terraform_iam_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.terraform_iam_provision.arn
}

resource "aws_iam_role_policy_attachment" "terraform_s3_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.terraform_s3_provision.arn
}

resource "aws_iam_role_policy_attachment" "terraform_dynamodb_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.terraform_dynamodb_provision.arn
}

resource "aws_iam_role_policy_attachment" "terraform_stepfunctions_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.terraform_stepfunctions_provision.arn
}

resource "aws_iam_role_policy_attachment" "terraform_lambda_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.terraform_lambda_provision.arn
}

// Attach AWS managed policies for additional permissions
resource "aws_iam_role_policy_attachment" "terraform_deployment_cloudformation" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
}

resource "aws_iam_role_policy_attachment" "terraform_deployment_ec2" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

// Additional runtime policies for TerraformDeploymentRole
// Consolidating all Lambda and Step Function runtime permissions into single role

resource "aws_iam_role_policy_attachment" "terraform_dynamodb_runtime_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.order_table_access.arn
}

resource "aws_iam_role_policy_attachment" "terraform_s3_upload_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.invoice_s3_upload.arn
}

resource "aws_iam_role_policy_attachment" "terraform_s3_location_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.invoice_s3_location.arn
}

resource "aws_iam_role_policy_attachment" "terraform_s3_list_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.invoice_s3_list.arn
}

resource "aws_iam_role_policy_attachment" "terraform_logs_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.cloudwatch_logs_write.arn
}

resource "aws_iam_role_policy_attachment" "terraform_stepfunction_exec_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.stepfunctions_exec.arn
}

resource "aws_iam_role_policy_attachment" "terraform_lambda_control_attach" {
  role       = aws_iam_role.TerraformDeploymentRole.name
  policy_arn = aws_iam_policy.lambda_control.arn
}
