variable "region" {
  default = "us-east-1"
  type = string
  description = "AWS region for deployment"
}



variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "order-fulfillment"
}



locals {
  endpoints = {

    startWorkflow = {
      path        = "startWorkflow"
      lambda_arn  = aws_lambda_function.start_workflow.invoke_arn
    }
    validateOrder = {
      path        = "validateOrder"
      lambda_arn  = aws_lambda_function.validate_order.invoke_arn
    }
    generateInvoice = {
      path        = "generateInvoice"
      lambda_arn  = aws_lambda_function.generate_invoice.invoke_arn
    }
    suggestShipping = {
      path        = "suggestShipping"
      lambda_arn  = aws_lambda_function.shipping_suggestion.invoke_arn
    }
    trackOrder = {
      path        = "trackOrder"
      lambda_arn  = aws_lambda_function.order_status_tracking.invoke_arn
    }
  }

  api_base_url = "https://${aws_api_gateway_rest_api.OrderProcessingAPI.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.Stage.stage_name}"

}
