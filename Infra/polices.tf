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
          aws_dynamodb_table.orders.arn,
          "${aws_dynamodb_table.orders.arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_kms_provision" {
  name        = "${var.project_name}-${var.environment}-TerraformKMSProvision-${random_id.bucket_suffix.hex}"
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
          "kms:GetKeyRotationStatus",
          "kms:DescribeKey",
          "kms:CreateAlias",
          "kms:UpdateAlias",
          "kms:DeleteAlias",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_apigateway_provision" {
  name        = "${var.project_name}-${var.environment}-TerraformAPIGatewayProvision-${random_id.bucket_suffix.hex}"
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
  name        = "${var.project_name}-${var.environment}-TerraformIAMProvision-${random_id.bucket_suffix.hex}"
  description = "Allow Terraform to create IAM roles and policies"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PassRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListAttachedRolePolicies",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:ListPolicyVersions",
          "iam:DeletePolicyVersion"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_s3_provision" {
  name        = "${var.project_name}-${var.environment}-TerraformS3Provision-${random_id.bucket_suffix.hex}"
  description = "Allow Terraform to create and configure S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketTagging",
          "s3:PutEncryptionConfiguration",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:GetEncryptionConfiguration",
          "s3:ListBucket",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
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
          "lambda:InvokeFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:ListFunctions",
          "lambda:UpdateFunctionConfiguration"
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
          "logs:PutLogEvents",
          "logs:DeleteLogGroup"
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
        Resource = "${aws_s3_bucket.invoice_storage.arn}/*"
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
        Resource = aws_s3_bucket.invoice_storage.arn
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
        Resource = aws_s3_bucket.invoice_storage.arn
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


resource "aws_iam_policy" "assume_deployment_role" {
  name        = "${var.project_name}-${var.environment}-AssumeDeploymentRolePolicy-${random_id.bucket_suffix.hex}"
  description = "Allows assuming TerraformDeploymentRole"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["sts:AssumeRole"],
        Resource = aws_iam_role.TerraformDeploymentRole.arn
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_dynamodb_provision" {
  name        = "${var.project_name}-${var.environment}-TerraformDynamoDBProvision-${random_id.bucket_suffix.hex}"
  description = "Allow Terraform to create and delete DynamoDB tables"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable",
          "dynamodb:UpdateTable",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:ListTagsOfResource"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_stepfunctions_provision" {
  name        = "${var.project_name}-${var.environment}-TerraformStepFunctionsProvision-${random_id.bucket_suffix.hex}"
  description = "Allow Terraform to create and delete Step Functions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "states:CreateStateMachine",
          "states:DeleteStateMachine",
          "states:DescribeStateMachine",
          "states:UpdateStateMachine",
          "states:TagResource",
          "states:UntagResource",
          "states:ListTagsForResource"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "terraform_lambda_provision" {
  name        = "${var.project_name}-${var.environment}-TerraformLambdaProvision-${random_id.bucket_suffix.hex}"
  description = "Allow Terraform to create and delete Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:GetFunction",
          "lambda:ListFunctions",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:TagResource",
          "lambda:UntagResource"
        ],
        Resource = "*"
      }
    ]
  })
}