// Attach policies to IAM roles for Lambda Functions
resource "aws_iam_role_policy_attachment" "lambda_control_attach" {
  role       = "Order_fullfillment_project_user.LambdaExcutionRole"
  policy_arn = aws_iam_policy.lambda_control.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs_attach" {
  role       = "Order_fullfillment_project_user.LambdaExcutionRole"
  policy_arn = aws_iam_policy.cloudwatch_logs_write.arn
}

resource "aws_iam_role_policy_attachment" "lambda_dynamo_attach" {
  role       = "Order_fullfillment_project_user.LambdaExcutionRole"
  policy_arn = aws_iam_policy.order_table_access.arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3_upload_attach" {
  role       = "Order_fullfillment_project_user.LambdaExcutionRole"
  policy_arn = aws_iam_policy.invoice_s3_upload.arn
}

// Attach policies to Step Function role
resource "aws_iam_role_policy_attachment" "stepfunctions_exec_attach" {
  role       = "Order_fullfillment_project_user.StepFunctionRole"
  policy_arn = aws_iam_policy.stepfunctions_exec.arn
}

resource "aws_iam_role_policy_attachment" "stepfunctions_lambda_attach" {
  role       = "Order_fullfillment_project_user.StepFunctionRole"
  policy_arn = aws_iam_policy.lambda_control.arn
}

resource "aws_iam_role_policy_attachment" "stepfunctions_dynamo_attach" {
  role       = "Order_fullfillment_project_user.StepFunctionRole"
  policy_arn = aws_iam_policy.order_table_access.arn
}

resource "aws_iam_role_policy_attachment" "stepfunctions_s3_attach" {
  role       = "Order_fullfillment_project_user.StepFunctionRole"
  policy_arn = aws_iam_policy.invoice_s3_upload.arn
}
