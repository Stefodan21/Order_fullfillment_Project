// api gateway for order processing
resource "aws_api_gateway_rest_api" "OrderProcessingAPI" {
    name = "OrderProcessingAPI"
    description = "API for Order Processing"    
    }


resource "aws_api_gateway_resource" "StartWorkflowResource" {
  rest_api_id = aws_api_gateway_rest_api.MainAPI.id
  parent_id   = aws_api_gateway_rest_api.MainAPI.root_resource_id
  path_part   = "startWorkflow"
}

resource "aws_api_gateway_method" "StartWorkflowPOST" {
  rest_api_id   = aws_api_gateway_rest_api.MainAPI.id
  resource_id   = aws_api_gateway_resource.StartWorkflowResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "StartWorkflowIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.MainAPI.id
  resource_id             = aws_api_gateway_resource.StartWorkflowResource.id
  http_method             = aws_api_gateway_method.StartWorkflowPOST.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.start_workflow.invoke_arn
}



resource "aws_api_gateway_resource" "ValidateOrderResource" {
  rest_api_id = aws_api_gateway_rest_api.OrderProcessingAPI.id
  parent_id   = aws_api_gateway_rest_api.OrderProcessingAPI.root_resource_id
  path_part   = "validateOrder"
}

resource "aws_api_gateway_method" "ValidateOrderPOST" {
  rest_api_id   = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id   = aws_api_gateway_resource.ValidateOrderResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "ValidateOrderIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id             = aws_api_gateway_resource.ValidateOrderResource.id
  http_method             = aws_api_gateway_method.ValidateOrderPOST.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.order_validation.invoke_arn
}

resource "aws_api_gateway_resource" "GenerateInvoiceResource" {
  rest_api_id = aws_api_gateway_rest_api.OrderProcessingAPI.id
  parent_id   = aws_api_gateway_rest_api.OrderProcessingAPI.root_resource_id
  path_part   = "generateInvoice"
}

resource "aws_api_gateway_method" "GenerateInvoicePOST" {
  rest_api_id   = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id   = aws_api_gateway_resource.GenerateInvoiceResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "GenerateInvoiceIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id             = aws_api_gateway_resource.GenerateInvoiceResource.id
  http_method             = aws_api_gateway_method.GenerateInvoicePOST.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.generate_invoice.invoke_arn
}

resource "aws_api_gateway_resource" "SuggestShippingResource" {
  rest_api_id = aws_api_gateway_rest_api.OrderProcessingAPI.id
  parent_id   = aws_api_gateway_rest_api.OrderProcessingAPI.root_resource_id
  path_part   = "suggestShipping"
}

resource "aws_api_gateway_method" "SuggestShippingPOST" {
  rest_api_id   = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id   = aws_api_gateway_resource.SuggestShippingResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "SuggestShippingIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id             = aws_api_gateway_resource.SuggestShippingResource.id
  http_method             = aws_api_gateway_method.SuggestShippingPOST.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.shipping_suggestion.invoke_arn
}

resource "aws_api_gateway_resource" "TrackOrderResource" {
  rest_api_id = aws_api_gateway_rest_api.OrderProcessingAPI.id
  parent_id   = aws_api_gateway_rest_api.OrderProcessingAPI.root_resource_id
  path_part   = "trackOrder"
}

resource "aws_api_gateway_method" "TrackOrderPOST" {
  rest_api_id   = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id   = aws_api_gateway_resource.TrackOrderResource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "TrackOrderIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id             = aws_api_gateway_resource.TrackOrderResource.id
  http_method             = aws_api_gateway_method.TrackOrderPOST.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.order_status_tracking.invoke_arn
}

resource "aws_api_gateway_deployment" "MainDeployment" {
  rest_api_id = aws_api_gateway_rest_api.OrderProcessingAPI.id
  depends_on = [
    aws_api_gateway_integration.ValidateOrderIntegration,
    aws_api_gateway_integration.GenerateInvoiceIntegration,
    aws_api_gateway_integration.SuggestShippingIntegration,
    aws_api_gateway_integration.TrackOrderIntegration,
    aws_api_gateway_integration.StartWorkflowIntegration
  ]
}

resource "aws_api_gateway_stage" "MainStage" {
  deployment_id = aws_api_gateway_deployment.MainDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.OrderProcessingAPI.id
  stage_name    = "prod"
}


