// S3 bucket for invoice storage
// Stores generated invoices and applies lifecycle rules for retention

resource "random_id" "bucket_suffix" {
  byte_length = 4
}


resource "aws_s3_bucket" "invoice_storage" {
    bucket = "invoicestorage-${var.project_name}-${random_id.bucket_suffix.hex}"
    lifecycle {
        prevent_destroy = true
    }

    tags = {
    Environment = var.environment
    Project     = var.project_name
  }

}

// s3 removes invoices after 1 year
resource "aws_s3_bucket_lifecycle_configuration" "invoice_storage_lifecycle" {
    bucket = aws_s3_bucket.invoice_storage.id
    rule {
        id   = "expire_old_invoices"
        status = "Enabled" 

        filter {
            prefix = "" # applies to all objects
        }     
        expiration {
            days = 365
        }
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "invoice_storage_encryption" {
  bucket = aws_s3_bucket.invoice_storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.data_encryption.arn
    }
  }
}

