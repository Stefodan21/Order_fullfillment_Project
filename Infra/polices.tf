// IAM policies for DynamoDB, Lambda, S3, and Step Functions access
// Each policy grants specific permissions required by the workflow components

// Locals for policy definitions to reduce duplication
locals {
  // Common policy naming pattern
  policy_name_prefix = "${var.project_name}-${var.environment}"
  policy_name_suffix = random_id.bucket_suffix.hex

  // Simple policies that can be consolidated with for_each
  simple_policies = {
    order_table_access = {
      description = "Policy to allow operations on the Order table in DynamoDB"
      policy_suffix = "AllowOrderTableOperations"
      statements = [
        {
          Sid    = "OrderTableAccess"
          Effect = "Allow"
          Action = [
            "dynamodb:GetItem",
            "dynamodb:PutItem", 
            "dynamodb:UpdateItem",
            "dynamodb:Query"
          ]
          Resource = [
            aws_dynamodb_table.orders.arn,
            "${aws_dynamodb_table.orders.arn}/index/*"
          ]
        }
      ]
    }

    invoice_s3_upload = {
      description = "Policy to allow uploading invoices to S3"
      policy_suffix = "AllowS3InvoiceUpload"
      statements = [
        {
          Effect = "Allow"
          Action = ["s3:PutObject"]
          Resource = "${aws_s3_bucket.invoice_storage.arn}/*"
        }
      ]
    }

    invoice_s3_location = {
      description = "Policy to allow S3 bucket location access"
      policy_suffix = "AllowS3InvoiceLocationAccess"
      statements = [
        {
          Effect = "Allow"
          Action = ["s3:GetBucketLocation"]
          Resource = aws_s3_bucket.invoice_storage.arn
        }
      ]
    }

    invoice_s3_list = {
      description = "Policy to allow listing invoice bucket"
      policy_suffix = "AllowS3InvoiceList"
      statements = [
        {
          Effect = "Allow"
          Action = ["s3:ListBucket"]
          Resource = aws_s3_bucket.invoice_storage.arn
        }
      ]
    }

    cloudwatch_logs_write = {
      description = "Policy to allow writing logs to CloudWatch"
      policy_suffix = "AllowCloudWatchLogsWrite"
      statements = [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Resource = "*"
        }
      ]
    }

    stepfunctions_exec = {
      description = "Policy to allow execution of a specific state machine"
      policy_suffix = "AllowStepFunctionsExecution"
      statements = [
        {
          Effect = "Allow"
          Action = [
            "states:StartExecution",
            "states:DescribeExecution",
            "states:GetExecutionHistory"
          ]
          Resource = aws_sfn_state_machine.OrderFullfillment.arn
        }
      ]
    }

    assume_deployment_role = {
      description = "Allows assuming TerraformDeploymentRole"
      policy_suffix = "AssumeDeploymentRolePolicy"
      statements = [
        {
          Effect = "Allow"
          Action = ["sts:AssumeRole"]
          Resource = aws_iam_role.TerraformDeploymentRole.arn
        }
      ]
    }
  }
}

// Consolidated simple policies using for_each
resource "aws_iam_policy" "simple_policies" {
  for_each = local.simple_policies

  name        = "${local.policy_name_prefix}-${each.value.policy_suffix}-${local.policy_name_suffix}"
  description = each.value.description

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = each.value.statements
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
          "kms:DescribeKey"
        ],
        Resource = [
          aws_kms_key.data_encryption.arn
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "kms:UpdateAlias"
        ],
        Resource = [
          aws_kms_alias.data_encryption_alias.arn
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
          "s3:DeleteBucket"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
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
        Sid    = "LambdaGlobalActions",
        Effect = "Allow",
        Action = [
          "lambda:CreateFunction",
          "lambda:ListFunctions"
        ],
        Resource = "*"
      },
      {
        Sid    = "LambdaFunctionOps",
        Effect = "Allow",
        Action = [
          "lambda:UpdateFunctionCode",
          "lambda:InvokeFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
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
      // CloudWatch Logs for Lambda function operations
      {
        Sid = "CloudWatchLogsManagement",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
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
        Resource = "*"
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
          "kms:DescribeKey"
        ],
        Resource = aws_kms_key.data_encryption.arn
      },
      {
        Sid = "KMSAliasManagement",
        Effect = "Allow",
        Action = [
          "kms:CreateAlias",
          "kms:DeleteAlias",
          "kms:UpdateAlias"
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
      // S3 permissions - split between global and resource-specific actions
      {
        Sid = "S3GlobalActions",
        Effect = "Allow",
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket"
        ],
        Resource = "*"
      },
      {
        Sid = "S3BucketProvisioning",
        Effect = "Allow",
        Action = [
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
        Resource = "*"
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
      // Lambda invocation for runtime operations only
      {
        Sid = "LambdaRuntimeSpecific",
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
      {
        Sid = "LambdaLogging",
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}