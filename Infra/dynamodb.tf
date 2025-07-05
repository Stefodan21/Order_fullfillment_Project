// For storing the information in dynamodb
resource "aws_dynamodb_table" "OrderDetails" {
  name         = "OrderDetails"
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

  # Optional: to support order_id lookups
  attribute {
    name = "order_id"
    type = "S"
  }

  # Optional: GSI if you want to query by order_id one day
  global_secondary_index {
    name            = "order_id-index"
    hash_key        = "order_id"
    projection_type = "ALL"
  }

  tags = {
    Environment = "dev"
    Project     = "OrderFulfillment"
  }
}
