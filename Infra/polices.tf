// IAM policies for DynamoDB, Lambda, S3, and Step Functions access
// Each policy grants specific permissions required by the workflow components
resource "aws_iam_policy" "order_table_access" {
  name        = "AllowOrderTableOperations"
  description = "Policy to allow operations on the Order table in DynamoDB"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "OrderTableAccess",
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query"
        ],
        Resource = [
          "arn:aws:dynamodb:us-east-1:478517495734:table/OrderDetails",
          "arn:aws:dynamodb:us-east-1:478517495734:table/OrderDetails/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_kms_provision" {
  name        = "${var.project_name}-${var.environment}-TerraformKMSProvision"
  description = "Allow Terraform to create and tag KMS keys"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kms:CreateKey",
          "kms:TagResource",
          "kms:PutKeyPolicy",
          "kms:EnableKeyRotation",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_apigateway_provision" {
  name        = "${var.project_name}-${var.environment}-TerraformAPIGatewayProvision"
  description = "Allow Terraform to create and tag API Gateway resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:GET",
          "apigateway:DELETE"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_iam_provision" {
  name        = "${var.project_name}-${var.environment}-TerraformIAMProvision"
  description = "Allow Terraform to create IAM roles and policies"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:PassRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:CreatePolicy",
          "iam:DeletePolicy"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_s3_provision" {
  name        = "${var.project_name}-${var.environment}-TerraformS3Provision"
  description = "Allow Terraform to create and configure S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:PutBucketPolicy",
          "s3:PutBucketTagging",
          "s3:PutEncryptionConfiguration",
          "s3:GetBucketLocation"
        ],
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_policy" "lambda_control" {
name        = "AllowLambdaOperations"
  description = "Policy to allow operations on Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "LambdaOps",
        Effect = "Allow",
        Action = [
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:InvokeFunction"
        ],
        Resource = [
          "arn:aws:lambda:us-east-1:478517495734:function:OrderValidation",
          "arn:aws:lambda:us-east-1:478517495734:function:InvoiceGenerator",
          "arn:aws:lambda:us-east-1:478517495734:function:ShippingSuggestion",
          "arn:aws:lambda:us-east-1:478517495734:function:OrderStatusTracking"
        ]
        
      },
      {
        Sid    = "LambdaLogging",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:us-east-1:*:*"
      }
    ]
  })
}

resource "aws_iam_policy" "invoice_s3_upload" {
  name        = "AllowS3InvoiceUpload"
  description = "Policy to allow uploading invoices to S3"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:PutObject"],
        Resource = "arn:aws:s3:::invoicestorage-ofp/*"
      }
    ]
  })
}

resource "aws_iam_policy" "invoice_s3_location" {
  name        = "AllowS3InvoiceLocationAccess"
  description = "Policy to allow S3 bucket location access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetBucketLocation"],
        Resource = "arn:aws:s3:::invoicestorage-ofp"
      }
    ]
  })
}

resource "aws_iam_policy" "invoice_s3_list" {
  name        = "AllowS3InvoiceList"
  description = "Policy to allow listing invoice bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = "arn:aws:s3:::invoicestorage-ofp"
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_logs_write" {
  name        = "AllowCloudWatchLogsWrite"
  description = "Policy to allow writing logs to CloudWatch"

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "arn:aws:logs:us-east-1:*:*"
    }]
  })
}

resource "aws_iam_policy" "stepfunctions_exec" {
  name        = "AllowStepFunctionsExecution"
  description = "Policy to allow execution of a specific state machine"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "states:StartExecution",
          "states:DescribeExecution",
          "states:GetExecutionHistory"
        ],
        Resource = "arn:aws:states:us-east-1:478517495734:stateMachine:OrderFullfillment"
      }
    ]
  })
}
