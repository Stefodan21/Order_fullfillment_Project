
resource "aws_lambda_function" "start_workflow" {
  function_name = "StartWorkflow"
  handler       = "StartWorkflow.lambda_handler"
  runtime       = "python3.9"
  role          = "arn:aws:iam::...:role/Order_fullfillment_project_user.StepFunctionTriggerRole"
  filename      = "${path.module}/start_workflow.zip"
  source_code_hash = filebase64sha256("${path.module}/start_workflow.zip")
}

// lambda function for order validation
resource "aws_lambda_function" "validate_order" {
    function_name = "OrderValidation"
    handler       = "order_validation.lambda_handler"
    runtime       = "python3.9"
    role          = "arn:aws:iam::478517495734:role/Order_fullfillment_project_user.LambdaExcutionRole" //arn role for lambda
    filename      = "order_validation.zip"
    source_code_hash = filebase64sha256("order_validation.zip")
    layers            = [aws_lambda_layer_version.shared_layer.arn]
}

// lambda function for invoice generation
resource "aws_lambda_function" "generate_invoice" {
    function_name = "InvoiceGenerator"
    handler = "InvoiceGenerator.lambda_handler"
    runtime = "python3.9"
    role = "arn:aws:iam::478517495734:role/Order_fullfillment_project_user.LambdaExcutionRole" //arn role for lambda
    filename = "invoice_generator.zip"
    source_code_hash = filebase64sha256("invoice_generator.zip") 
    layers            = [aws_lambda_layer_version.shared_layer.arn]           
}

// lambda function for shipping suggestion
resource "aws_lambda_function" "shipping_suggestion" {
    function_name = "ShippingSuggestion"
    handler = "ShippingSuggestion.lambda_handler"
    runtime = "python3.9"
    role = "arn:aws:iam::478517495734:role/Order_fullfillment_project_user.LambdaExcutionRole" //arn role for lambda
    filename = "shipping_suggestion.zip"
    source_code_hash = filebase64sha256("shipping_suggestion.zip")     
    layers            = [aws_lambda_layer_version.shared_layer.arn]       
}

// lambda function for order status tracking
resource "aws_lambda_function" "order_status_tracking" {
    function_name = "OrderStatusTracking"
    handler = "OrderStatusTracking.lambda_handler"
    runtime = "python3.9"
    role = "arn:aws:iam::478517495734:role/Order_fullfillment_project_user.LambdaExcutionRole" //arn role for lambda
    filename = "order_status_tracking.zip"
    source_code_hash = filebase64sha256("order_status_tracking.zip")  
    layers            = [aws_lambda_layer_version.shared_layer.arn]          
}  
