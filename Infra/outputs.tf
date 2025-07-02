output "api_url" {
  value = aws_api_gateway_deployment.OrderProcessingDeployment.invoke_url
}

output "s3_bucket" {
  value = aws_s3_bucket.invoice_storage_ofp.bucket
}
