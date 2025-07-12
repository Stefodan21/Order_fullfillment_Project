// Terraform and AWS provider configuration
// Sets up the AWS provider and required Terraform providers
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
        }
    }
}

provider "aws" {
    region = var.region
}