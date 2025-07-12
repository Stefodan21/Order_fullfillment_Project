output "order_api_url" {
  value = "https://${aws_api_gateway_rest_api.OrderProcessingAPI.id}.execute-api.${var.region}.amazonaws.com/${aws_api_gateway_stage.OrderProcessingStage.stage_name}/processOrder"
}
output "start_workflow_url" {
  value = "${output.api_base_url}/startWorkflow"
}
output "validate_order_url" {
  value = "${output.api_base_url}/validateOrder"
}

output "generate_invoice_url" {
  value = "${output.api_base_url}/generateInvoice"
}

output "suggest_shipping_url" {
  value = "${output.api_base_url}/suggestShipping"
}

output "track_order_url" {
  value = "${output.api_base_url}/trackOrder"
}