
resource "aws_lambda_function" "start_workflow" {
  function_name =  "${var.project_name}-${var.environment}-startWorkflow"
  handler       = "StartWorkflow.lambda_handler"
  runtime       = "python3.9"
  role          = "aws_iam_role.StepFunctionTriggerRole.arn"
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
    function_name = "${var.project_name}-${var.environment}-OrderValidation"
    handler       = "order_validation.lambda_handler"
    runtime       = "python3.9"
    role          = "aws_iam_role.LambdaExecutionRole.arn"
    filename      = "${path.module}/order_validation.zip"
    source_code_hash = filebase64sha256("order_validation.zip")
    layers            = [aws_lambda_layer_version.shared_layer.arn]

      tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

// lambda function for invoice generation
resource "aws_lambda_function" "generate_invoice" {
    function_name = "${var.project_name}-${var.environment}-InvoiceGenerator"
    handler = "InvoiceGenerator.lambda_handler"
    runtime = "python3.9"
    role = "aws_iam_role.LambdaExecutionRole.arn"
    filename = "${path.module}/invoice_generator.zip"
    source_code_hash = filebase64sha256("invoice_generator.zip") 
    layers            = [aws_lambda_layer_version.shared_layer.arn]   

      tags = {
    Environment = var.environment
    Project     = var.project_name
  }        
}

// lambda function for shipping suggestion
resource "aws_lambda_function" "shipping_suggestion" {
    function_name = "${var.project_name}-${var.environment}-ShippingSuggestion"
    handler = "ShippingSuggestion.lambda_handler"
    runtime = "python3.9"
    role = "aws_iam_role.StepFunctionTriggerRole.arn" //arn role for lambda
    filename = "${path.module}/shipping_suggestion.zip"
    source_code_hash = filebase64sha256("shipping_suggestion.zip")     
    layers            = [aws_lambda_layer_version.shared_layer.arn]     

      tags = {
    Environment = var.environment
    Project     = var.project_name
  }  
}

// lambda function for order status tracking
resource "aws_lambda_function" "order_status_tracking" {
    function_name = "${var.project_name}-${var.environment}-OrderStatusTracking"
    handler = "OrderStatusTracking.lambda_handler"
    runtime = "python3.9"
    role = "aws_iam_role.LambdaExecutionRole.arn" //arn role for lambda
    filename = "${path.module}/order_status_tracking.zip"
    source_code_hash = filebase64sha256("order_status_tracking.zip")
    layers            = [aws_lambda_layer_version.shared_layer.arn]
    tags = {
      Environment = var.environment
      Project     = var.project_name
    }
}
