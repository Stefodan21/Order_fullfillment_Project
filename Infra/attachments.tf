// IAM policy attachments for Lambda and Step Function roles
// This file attaches necessary policies to roles for logging, DynamoDB, and S3 access
// Attach policies to IAM roles for Lambda Functions
resource "aws_iam_role_policy_attachment" "lambda_exec_logs" {
  role       = aws_iam_role.LambdaExecutionRole.name
  policy_arn = aws_iam_policy.cloudwatch_logs_write.arn
}

resource "aws_iam_role_policy_attachment" "lambda_exec_dynamo" {
  role       = aws_iam_role.LambdaExecutionRole.name
  policy_arn = aws_iam_policy.order_table_access.arn
}

resource "aws_iam_role_policy_attachment" "lambda_exec_s3_upload" {
  role       = aws_iam_role.LambdaExecutionRole.name
  policy_arn = aws_iam_policy.invoice_s3_upload.arn
}

resource "aws_iam_role_policy_attachment" "lambda_exec_s3_location" {
  role       = aws_iam_role.LambdaExecutionRole.name
  policy_arn = aws_iam_policy.invoice_s3_location.arn
}

resource "aws_iam_role_policy_attachment" "lambda_exec_s3_list" {
  role       = aws_iam_role.LambdaExecutionRole.name
  policy_arn = aws_iam_policy.invoice_s3_list.arn
}

resource "aws_iam_role_policy_attachment" "step_trigger_logs" {
  role       = aws_iam_role.StepFunctionTriggerRole.name
  policy_arn = aws_iam_policy.cloudwatch_logs_write.arn
}

resource "aws_iam_role_policy_attachment" "step_trigger_exec" {
  role       = aws_iam_role.StepFunctionTriggerRole.name
  policy_arn = aws_iam_policy.stepfunctions_exec.arn
}

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

