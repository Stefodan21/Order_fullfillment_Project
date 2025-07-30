// IAM policies for DynamoDB, Lambda, S3, and Step Functions access
// Each policy grants specific permissions required by the workflow components
resource "aws_iam_policy" "order_table_access" {
  name        = "${var.project_name}-${var.environment}-AllowOrderTableOperations-${random_id.bucket_suffix.hex}"
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
          "kms:UpdateAlias"
        ],
        Resource = [
          aws_kms_key.data_encryption.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:CreateAlias",
          "kms:DeleteAlias"
        ],
        Resource = [
          aws_kms_alias.data_encryption_alias.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = [
          aws_kms_key.data_encryption.arn
        ],
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "us-east-1"
          }
        }
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
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.invoice_storage.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ],
        Resource = [
          "${aws_s3_bucket.invoice_storage.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_policy" "lambda_control" {
  name        = "${var.project_name}-${var.environment}-AllowLambdaOperations-${random_id.bucket_suffix.hex}"
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
          aws_lambda_function.start_workflow.arn,
          aws_lambda_function.validate_order.arn,
          aws_lambda_function.generate_invoice.arn,
          aws_lambda_function.shipping_suggestion.arn,
          aws_lambda_function.order_status_tracking.arn
        ]
        
      },
      // CloudWatch Logs for both Lambda and Step Functions
      {
        Sid = "CloudWatchLogsCleanup",
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

// Lambda-specific runtime execution policy (minimal permissions for Lambda functions only)
resource "aws_iam_policy" "lambda_runtime_execution" {
  name        = "${var.project_name}-${var.environment}-LambdaRuntimeExecution-${random_id.bucket_suffix.hex}"
  description = "Minimal runtime permissions for Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      // DynamoDB access for order processing
      {
        Sid = "DynamoDBAccess",
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
      },
      // S3 access for invoice storage
      {
        Sid = "S3InvoiceAccess",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.invoice_storage.arn,
          "${aws_s3_bucket.invoice_storage.arn}/*"
        ]
      },
      // CloudWatch Logs for Lambda logging
      {
        Sid = "CloudWatchLogs",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:us-east-1:*:log-group:/aws/lambda/${var.project_name}-${var.environment}-*:*"
      }
    ]
  })
}

// Step Functions-specific runtime execution policy (minimal permissions for orchestration only)
resource "aws_iam_policy" "step_function_runtime_execution" {
  name        = "${var.project_name}-${var.environment}-StepFunctionRuntimeExecution-${random_id.bucket_suffix.hex}"
  description = "Minimal runtime permissions for Step Functions orchestration"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      // Lambda invocation for orchestration
      {
        Sid = "LambdaInvocation",
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = [
          aws_lambda_function.start_workflow.arn,
          aws_lambda_function.validate_order.arn,
          aws_lambda_function.generate_invoice.arn,
          aws_lambda_function.shipping_suggestion.arn,
          aws_lambda_function.order_status_tracking.arn
        ]
      },
      // CloudWatch Logs for Step Functions logging
      {
        Sid = "CloudWatchLogs",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:us-east-1:*:log-group:/aws/stepfunctions/${var.project_name}-${var.environment}-*:*"
      }
    ]
  })
}

resource "aws_iam_policy" "invoice_s3_upload" {
  name        = "${var.project_name}-${var.environment}-AllowS3InvoiceUpload-${random_id.bucket_suffix.hex}"
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
  name        = "${var.project_name}-${var.environment}-AllowS3InvoiceLocationAccess-${random_id.bucket_suffix.hex}"
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
  name        = "${var.project_name}-${var.environment}-AllowS3InvoiceList-${random_id.bucket_suffix.hex}"
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
  name        = "${var.project_name}-${var.environment}-AllowCloudWatchLogsWrite-${random_id.bucket_suffix.hex}"
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
  name        = "${var.project_name}-${var.environment}-AllowStepFunctionsExecution-${random_id.bucket_suffix.hex}"
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
        Resource = aws_sfn_state_machine.OrderFullfillment.arn
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

// Consolidated infrastructure provisioning policy (combines 7 individual policies)
resource "aws_iam_policy" "terraform_infrastructure_provisioning" {
  name        = "${var.project_name}-${var.environment}-TerraformInfrastructureProvisioning-${random_id.bucket_suffix.hex}"
  description = "Consolidated policy for all Terraform infrastructure provisioning operations"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      // KMS permissions
      {
        Sid = "KMSProvisioning",
        Effect = "Allow",
        Action = [
          "kms:CreateKey",
          "kms:TagResource",
          "kms:PutKeyPolicy",
          "kms:EnableKeyRotation",
          "kms:GetKeyRotationStatus",
          "kms:DescribeKey",
          "kms:UpdateAlias"
        ],
        Resource = aws_kms_key.data_encryption.arn
      },
      {
        Sid = "KMSAliasProvisioning",
        Effect = "Allow",
        Action = [
          "kms:CreateAlias",
          "kms:DeleteAlias"
        ],
        Resource = aws_kms_alias.data_encryption_alias.arn
      },
      {
        Sid = "KMSDestruction",
        Effect = "Allow",
        Action = [
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        Resource = aws_kms_key.data_encryption.arn,
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "us-east-1"
          }
        }
      },
      // API Gateway permissions
      {
        Sid = "APIGatewayProvisioning",
        Effect = "Allow",
        Action = [
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:GET",
          "apigateway:DELETE"
        ],
        Resource = "*"
      },
      // IAM permissions
      {
        Sid = "IAMProvisioning",
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
      },
      // S3 permissions
      {
        Sid = "S3BucketProvisioning",
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
          "s3:ListBucket"
        ],
        Resource = aws_s3_bucket.invoice_storage.arn
      },
      {
        Sid = "S3ObjectProvisioning",
        Effect = "Allow",
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ],
        Resource = "${aws_s3_bucket.invoice_storage.arn}/*"
      },
      // DynamoDB permissions
      {
        Sid = "DynamoDBProvisioning",
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
      },
      // Step Functions permissions
      {
        Sid = "StepFunctionsProvisioning",
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
      },
      // Lambda permissions
      {
        Sid = "LambdaProvisioning",
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

// Consolidated runtime execution policy (combines 6 individual policies)
resource "aws_iam_policy" "terraform_runtime_execution" {
  name        = "${var.project_name}-${var.environment}-TerraformRuntimeExecution-${random_id.bucket_suffix.hex}"
  description = "Consolidated policy for all Lambda and Step Function runtime operations"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      // DynamoDB runtime access
      {
        Sid = "DynamoDBRuntime",
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
      },
      // S3 runtime access
      {
        Sid = "S3RuntimeUpload",
        Effect = "Allow",
        Action = ["s3:PutObject"],
        Resource = "${aws_s3_bucket.invoice_storage.arn}/*"
      },
      {
        Sid = "S3RuntimeLocation",
        Effect = "Allow",
        Action = ["s3:GetBucketLocation"],
        Resource = aws_s3_bucket.invoice_storage.arn
      },
      {
        Sid = "S3RuntimeList",
        Effect = "Allow",
        Action = ["s3:ListBucket"],
        Resource = aws_s3_bucket.invoice_storage.arn
      },
      // CloudWatch Logs
      {
        Sid = "CloudWatchLogsRuntime",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:us-east-1:*:*"
      },
      // Step Functions execution
      {
        Sid = "StepFunctionsRuntime",
        Effect = "Allow",
        Action = [
          "states:StartExecution",
          "states:DescribeExecution",
          "states:GetExecutionHistory"
        ],
        Resource = aws_sfn_state_machine.OrderFullfillment.arn
      },
      // Lambda control/invocation
      {
        Sid = "LambdaRuntime",
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
          aws_lambda_function.start_workflow.arn,
          aws_lambda_function.validate_order.arn,
          aws_lambda_function.generate_invoice.arn,
          aws_lambda_function.shipping_suggestion.arn,
          aws_lambda_function.order_status_tracking.arn
        ]
      },
      {
        Sid = "LambdaLogging",
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