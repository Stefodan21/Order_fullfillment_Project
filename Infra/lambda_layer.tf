// Lambda Layer for shared dependencies
// This layer is used to share Python packages across multiple Lambda functions
resource "aws_lambda_layer_version" "shared_layer" {
  layer_name  = "shared_dependencies"
  description = "Layer for shared Python packages"
  compatible_runtimes = ["python3.9"]

  filename         = "layer.zip"
  source_code_hash = filebase64sha256("layer.zip")
}
