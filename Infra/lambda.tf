// Lambda function definitions for the order fulfillment workflow
// Includes functions for starting workflow, order validation, invoice generation, shipping suggestion, and order tracking

locals {
  # Calculate base prefix length to ensure function names stay under 64 character AWS limit
  base_prefix = "${var.project_name}-${var.environment}"
  suffix = random_id.bucket_suffix.hex
  
  # Function name templates with length validation (AWS Lambda limit: 64 chars)
  function_names = {
    start_workflow        = substr("${local.base_prefix}-startWorkflow", 0, 64)
    validate_order       = substr("${local.base_prefix}-OrderValidation-${local.suffix}", 0, 64)
    generate_invoice     = substr("${local.base_prefix}-InvoiceGenerator", 0, 64)
    shipping_suggestion  = substr("${local.base_prefix}-ShippingSuggestion", 0, 64)
    order_status_tracking = substr("${local.base_prefix}-OrderStatusTracking", 0, 64)
  }
}

resource "aws_lambda_function" "start_workflow" {
  function_name =  local.function_names.start_workflow
  handler       = "start_workflow.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.LambdaExecutionRole.arn
  filename      = "${path.module}/start_workflow.zip"
  source_code_hash = filebase64sha256("${path.module}/start_workflow.zip")

  environment {
  variables = {
    STATE_MACHINE_ARN = aws_sfn_state_machine.OrderFullfillment.arn
  } 
 }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

// lambda function for order validation
resource "aws_lambda_function" "validate_order" {
    function_name = local.function_names.validate_order
    handler       = "order_validation.lambda_handler"
    runtime       = "python3.9"
    role          = aws_iam_role.LambdaExecutionRole.arn
    filename      = "${path.module}/order_validation.zip"
    source_code_hash = filebase64sha256("${path.module}/order_validation.zip")
    

      tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

// lambda function for invoice generation
resource "aws_lambda_function" "generate_invoice" {
    function_name = local.function_names.generate_invoice
    handler = "invoice_generator.lambda_handler"
    runtime = "python3.9"
    role = aws_iam_role.LambdaExecutionRole.arn
    filename = "${path.module}/invoice_generator.zip"
    source_code_hash = filebase64sha256("${path.module}/invoice_generator.zip") 
       

      tags = {
    Environment = var.environment
    Project     = var.project_name
  }        
}

// lambda function for shipping suggestion
resource "aws_lambda_function" "shipping_suggestion" {
    function_name = local.function_names.shipping_suggestion
    handler = "shipping_suggestion.lambda_handler"
    runtime = "python3.9"
    role = aws_iam_role.LambdaExecutionRole.arn
    filename = "${path.module}/shipping_suggestion.zip"
    source_code_hash = filebase64sha256("${path.module}/shipping_suggestion.zip")     
         

      tags = {
    Environment = var.environment
    Project     = var.project_name
  }  
}

// lambda function for order status tracking
resource "aws_lambda_function" "order_status_tracking" {
    function_name = local.function_names.order_status_tracking
    handler = "order_status_tracking.lambda_handler"
    runtime = "python3.9"
    role = aws_iam_role.LambdaExecutionRole.arn
    filename = "${path.module}/order_status_tracking.zip"
    source_code_hash = filebase64sha256("${path.module}/order_status_tracking.zip")
    
    tags = {
      Environment = var.environment
      Project     = var.project_name
    }
}
