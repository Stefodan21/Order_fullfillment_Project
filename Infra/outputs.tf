output "region" {
  description = "The AWS region used for deployment."
  value       = var.region
}


output "default_tags" {
  value = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

// Output variables for API URLs and default tags
// These outputs make it easy to reference key endpoints and tags from other modules or the CLI
// The API base URL is constructed from the API Gateway and stage resources
output "order_api_url" {
  value = "${local.api_base_url}/processOrder"
}

# All of these formerly used `output.api_base_url` and now use the local
output "start_workflow_url" {
  value = "${local.api_base_url}/startWorkflow"
}
output "validate_order_url" {
  value = "${local.api_base_url}/validateOrder"
}
output "generate_invoice_url" {
  value = "${local.api_base_url}/generateInvoice"
}
output "suggest_shipping_url" {
  value = "${local.api_base_url}/suggestShipping"
}
output "track_order_url" {
  value = "${local.api_base_url}/trackOrder"
}