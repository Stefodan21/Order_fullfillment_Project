resource "aws_dynamodb_table" "orders" {
  name         = "orders-${var.project_name}-${var.environment}-${random_id.bucket_suffix.hex}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "order_id"
  range_key    = "OrderedAt"

  attribute {
    name = "order_id"
    type = "S"
  }

  attribute {
    name = "OrderedAt"
    type = "S"
  }

  global_secondary_index {
    name            = "order_id-index"
    hash_key        = "order_id"
    projection_type = "ALL"
  }

  server_side_encryption {
    enabled     = true
    kms_key_arn = aws_kms_key.data_encryption.arn
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
