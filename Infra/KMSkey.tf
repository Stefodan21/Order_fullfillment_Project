resource "aws_kms_key" "data_encryption" {
  description             = "KMS key for encrypting S3 and DynamoDB"
  deletion_window_in_days = 10
  # enable_key_rotation     = true  # Disabled to avoid permission issues during initial deployment

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_kms_alias" "data_encryption_alias" {
  name          = "alias/${lower(var.project_name)}-${var.environment}-data-key"
  target_key_id = aws_kms_key.data_encryption.key_id
}

