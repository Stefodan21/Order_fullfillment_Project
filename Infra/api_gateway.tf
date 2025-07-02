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