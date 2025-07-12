// API Gateway resources for order processing
// This file defines the REST API, endpoints, and integrations for the order fulfillment workflow
resource "aws_api_gateway_rest_api" "OrderProcessingAPI" {
    name = "${var.project_name}-${var.environment}-OrderProcessingAPI"
    description = "API for ${var.project_name} ${var.environment}"    

    tags = {
      Environment = var.environment
      Project     = var.project_name
     }
  }




locals {
  order_endpoints = {
    validateOrder     = aws_lambda_function.order_validation.invoke_arn
    generateInvoice   = aws_lambda_function.generate_invoice.invoke_arn
    suggestShipping   = aws_lambda_function.shipping_suggestion.invoke_arn
    trackOrder        = aws_lambda_function.order_status_tracking.invoke_arn
  }
}

resource "aws_api_gateway_resource" "OrderEndpointResource" {
  for_each   = local.order_endpoints
  rest_api_id = aws_api_gateway_rest_api.OrderProcessingAPI.id
  parent_id   = aws_api_gateway_rest_api.OrderProcessingAPI.root_resource_id
  path_part   = each.key
}

resource "aws_api_gateway_method" "OrderEndpointPOST" {
  for_each   = local.order_endpoints
  rest_api_id   = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id   = aws_api_gateway_resource.OrderEndpointResource[each.key].id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "OrderEndpointIntegration" {
  for_each   = local.order_endpoints
  rest_api_id             = aws_api_gateway_rest_api.OrderProcessingAPI.id
  resource_id             = aws_api_gateway_resource.OrderEndpointResource[each.key].id
  http_method             = aws_api_gateway_method.OrderEndpointPOST[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = each.value
}

resource "aws_api_gateway_deployment" "workflowDeployment" {
  rest_api_id = aws_api_gateway_rest_api.OrderProcessingAPI.id
  
  triggers = {
    redeploy = timestamp()
  }
  depends_on = [for i in aws_api_gateway_integration.OrderEndpointIntegration : i]
}




resource "aws_api_gateway_stage" "Stage" {
  deployment_id = aws_api_gateway_deployment.workflowDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.OrderProcessingAPI.id
  stage_name    = var.environment
}


