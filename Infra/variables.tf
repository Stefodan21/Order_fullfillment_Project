variable "region" {
  default = "us-east-1"
  type = string
  description = "AWS region for deployment"
}



variable "project_name" {
  type    = string
  default = "order-fulfillment"
  
  validation {
    condition     = length(var.project_name) <= 20
    error_message = "Project name must be 20 characters or less to ensure Lambda function names stay under AWS 64-character limit."
  }
}

variable "environment" {
  type    = string
  default = "dev"
  
  validation {
    condition     = length(var.environment) <= 10
    error_message = "Environment name must be 10 characters or less to ensure Lambda function names stay under AWS 64-character limit."
  }
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

# Security variables for IAM trust policies - commented out for GitHub secrets workflow
# Uncomment these if you want to add IP/MFA restrictions to the deployment role

# variable "allowed_ip_ranges" {
#   description = "List of IP CIDR blocks allowed to assume deployment role. Leave empty to disable IP restrictions."
#   type        = list(string)
#   default     = []
#   # Example values:
#   # default = [
#   #   "203.0.113.0/24",   # Your office IP range
#   #   "198.51.100.0/24"   # GitHub Actions IP range (if using self-hosted runners)
#   # ]
# }

# variable "require_mfa" {
#   description = "Whether to require MFA for deployment role assumption"
#   type        = bool
#   default     = false
# }
