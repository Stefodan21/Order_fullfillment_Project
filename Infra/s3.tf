// S3 bucket for invoice storage
// Stores generated invoices and applies lifecycle rules for retention
resource "aws_s3_bucket" "invoice_storage_ofp" {
    bucket = "invoicestorage-ofp"
    lifecycle {
        prevent_destroy = true
    }

}

// s3 removes invoices after 1 year
resource "aws_s3_bucket_lifecycle_configuration" "invoice_storage_lifecycle" {
    bucket = aws_s3_bucket.invoice_storage_ofp.id
    rule {
        id   = "expire_old_invoices"
        status = "Enabled"      
        expiration {
            days = 365
        }
    }
}
