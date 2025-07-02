
// api gateway for order processing
resource "aws_api_gateway_rest_api" "OrderProcessingAPI" {
    name = "OrderProcessingAPI"
    description = "API for Order Processing"    
}

resource "aws_api_gateway_method" "OrderProcessingPOST" {
  rest_api_id   = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id   = aws_api_gateway_resource.OrderProcessingResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "OrderProcessingIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id             = aws_api_gateway_resource.OrderProcessingResource.id
  http_method             = aws_api_gateway_method.OrderProcessingPOST.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.validate_order.invoke_arn
}


resource "aws_api_gateway_resource" "OrderProcessingResource" {
    rest_api_id = aws_api_gateway_rest_api.OrderProcessingAPI.id
    parent_id   = aws_api_gateway_rest_api.OrderProcessingAPI.root_resource_id
    path_part   = "processOrder"
}

// workflow outline 
resource "aws_sfn_state_machine" "OrderFullfillment" {
    name = "OrderProcessing"
    role_arn = "arn:aws:iam::478517495734:role/Order_fullfillment_project_user.StepFunctionRole" //arn role for step function
    definition = <<EOF
    {
        "StartAt" : "OrderValidation",
        "States": {
            "OrderValidation": {
                "Type": "Task",
                "Resource": "${aws_lambda_function.validate_order.arn}",
                "Next": "InvoiceGeneration"
            },
            "InvoiceGeneration": {
                "Type": "Task",
                "Resource": "${aws_lambda_function.generate_invoice.arn}",
                "Next":"ShippingRecommendation"
            },
            "ShippingRecommendation": {
                "Type": "Task",
                "Resource": "${aws_lambda_function.shipping_suggestion.arn}",
                "Next":"StatusTracking",
            },
            "StatusTracking": {
                "Type": "Task"
                "Resource":"${aws_lambda_function.order_status_tracking.arn}",
                "End": true
            }
        }


    }
    EOF

}   
// lambda function for order validation
resource "aws_lambda_function" "validate_order" {
    function_name = "OrderValidation"
    handler       = "order_validation.lambda_handler"
    runtime       = "python3.9.5"
    role          = "arn:aws:iam::478517495734:role/Order_fullfillment_project_user.LambdaExcutionRole" //arn role for lambda
    filename      = "order_validation.zip"
    source_code_hash = filebase64sha256("order_validation.zip")
}

// lambda function for invoice generation
resource "aws_lambda_function" "generate_invoice" {
    function_name = "InvoiceGenerator"
    handler = "InvoiceGenerator.lambda_handler"
    runtime = "python3.9.5"
    role = "arn:aws:iam::478517495734:role/Order_fullfillment_project_user.LambdaExcutionRole" //arn role for lambda
    filename = "invoice_generator.zip"
    source_code_hash = filebase64sha256("invoice_generator.zip")            
}

// lambda function for shipping suggestion
resource "aws_lambda_function" "shipping_suggestion" {
    function_name = "ShippingSuggestion"
    handler = "ShippingSuggestion.lambda_handler"
    runtime = "python3.9.5"
    role = "arn:aws:iam::478517495734:role/Order_fullfillment_project_user.LambdaExcutionRole" //arn role for lambda
    filename = "shipping_suggestion.zip"
    source_code_hash = filebase64sha256("shipping_suggestion.zip")            
}

// lambda function for order status tracking
resource "aws_lambda_function" "order_status_tracking" {
    function_name = "OrderStatusTracking"
    handler = "OrderStatusTracking.lambda_handler"
    runtime = "python3.9.5"
    role = "arn:aws:iam::478517495734:role/Order_fullfillment_project_user.LambdaExcutionRole" //arn role for lambda
    filename = "order_status_tracking.zip"
    source_code_hash = filebase64sha256("order_status_tracking.zip")            
}  

// s3 bucket for invoice storage
resource "aws_s3_bucket" "invoice_storage_ofp" {
    bucket = "invoicestorage-ofp"
    lifecycle {
        prevent_destroy = true
    }

}

// s3 removes invoices after 1 year
resource "aws_s3_bucket_lifecycle_configuration" "invoice_storage_lifecycle" {
    bucket = aws_s3_bucket.invoice_storage_ofp.id
    rule {
        id   = "expire_old_invoices"
        status = "Enabled"      
        expiration {
            days = 365
        }
    }
}


// For storing the information in dynamodb
resource "aws_dynamodb_table" "CustomerDetails" {
  name         = "CustomerDetails"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "customer_name"
  range_key    = "OrderedAt"

  attribute {
    name = "customer_name"
    type = "S"
  }

  attribute {
    name = "OrderedAt"
    type = "S"
  }

  # Optional: to support order_id lookups
  attribute {
    name = "order_id"
    type = "S"
  }

  # Optional: GSI if you want to query by order_id one day
  global_secondary_index {
    name            = "order_id-index"
    hash_key        = "order_id"
    projection_type = "ALL"
  }

  tags = {
    Environment = "dev"
    Project     = "OrderFulfillment"
  }
}



// cloudwatch for monitoring
resource "aws_cloudwatch_dashboard" "cloudwatchMonitoring" {
    dashboard_name = "OrderProcessingMonitoring"
    dashboard_body = <<EOF
    {
        "widgets": [
            {
                "type": "metric",
                "x": 0,
                "y": 0,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "${aws_lambda_function.validate_order.arn}", "Invocations" ]
                    ],
                    "period": 300,
                    "stat": "Sum",
                    "region": "${us-east-1}",
                    "title": "Lambda Invocations"
                }
            }
        ]
    }
    EOF
}





