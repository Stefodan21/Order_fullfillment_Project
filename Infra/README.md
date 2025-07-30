# Infrastructure Setup Guide

This directory contains Terraform configuration for deploying the Order Fullfillment infrastructure to AWS.

**Note:** The directory name contains a spelling inconsistency ("fullfillment" vs "fulfillment"). This will be corrected in a future update to avoid breaking existing setups.

## Prerequisites

### 1. Create Terraform State Bucket (One-time setup)

Before running Terraform, you need to create an S3 bucket for storing Terraform state:

```bash
# Get your AWS account ID and create a unique bucket name
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "Your Account ID is: $ACCOUNT_ID"

# Create the state storage bucket
aws s3 mb s3://tfstatestorage-${ACCOUNT_ID}

# Enable versioning for state file safety
aws s3api put-bucket-versioning --bucket tfstatestorage-${ACCOUNT_ID} --versioning-configuration Status=Enabled

echo "Created state bucket: tfstatestorage-${ACCOUNT_ID}"
```

### 2. Configure Terraform Backend

Update `provider.tf` with your bucket name:

```hcl
terraform {
  backend "s3" {
    bucket = "tfstatestorage-YOUR_ACCOUNT_ID"  # Replace with your actual bucket name
    key    = "order-fulfillment/terraform.tfstate"
    region = "us-east-1"
  }
}
```

**Important:** Replace `YOUR_ACCOUNT_ID` with the actual account ID from step 1.

## Quick Start

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your configuration:**
   ```hcl
   deployer_principal_arn = "arn:aws:iam::YOUR_ACCOUNT_ID:user/YOUR_USERNAME"
   project_name = "order-fulfillment"  # Correct spelling (single 'l')
   environment = "dev"
   region = "us-east-1"
   ```

   **Note:** Use the correct spelling "fulfillment" (single 'l') to avoid propagating the typo to AWS resources.

3. **Deploy the infrastructure:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Required Variables

### `deployer_principal_arn` (Required)
The ARN of the IAM principal (user or role) that can assume the TerraformDeploymentRole.

**Examples:**
- Local development: `"arn:aws:iam::123456789012:user/terraform-user"`
- CI/CD (GitHub Actions): `"arn:aws:iam::123456789012:role/github-actions-role"`

**Security Note:** This principal will have permissions to deploy and manage AWS infrastructure. Ensure it follows your organization's security policies.

## Infrastructure Overview

The Terraform configuration creates:
- **IAM Roles**: Separate roles for deployment vs runtime execution (least-privilege)
- **Lambda Functions**: Order processing workflow functions
- **Step Functions**: Orchestrates the order fulfillment workflow
- **DynamoDB**: Order data storage
- **S3**: Invoice storage with encryption
- **API Gateway**: REST endpoints for order operations

## Security Features

- **Role Separation**: Deployment role separate from runtime execution roles
- **Cross-Account Protection**: AWS account restrictions in trust policies
- **Confused Deputy Prevention**: Source ARN validation
- **Encryption**: KMS encryption for S3 and DynamoDB
- **Least Privilege**: Minimal permissions for each role

## Troubleshooting

### Directory Name Spelling Issue
**IMPORTANT:** The current directory name contains a typo: `Order_fullfillment_Project` (double 'l' in "fullfillment").

**To fix this inconsistency:**
```bash
# 1. Rename the directory (from project parent folder)
mv Order_fullfillment_Project Order_fulfillment_Project

# 2. Update any local git remotes if needed
cd Order_fulfillment_Project
git remote set-url origin https://github.com/USERNAME/Order_fulfillment_Project

# 3. Recreate virtual environment with correct paths
rm -rf venv
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install -r requirements.txt
```

**Files that reference the old spelling:**
- GitHub repository URLs
- Virtual environment paths  
- Project documentation
- CI/CD configurations (if any)

### "Invalid deployer_principal_arn"
Ensure the ARN follows the correct format:
- User: `arn:aws:iam::ACCOUNT_ID:user/USERNAME`
- Role: `arn:aws:iam::ACCOUNT_ID:role/ROLENAME`

### "Circular dependency" errors
This has been resolved in the current configuration using ArnLike patterns instead of direct resource references.

### Lambda function naming
Function names are automatically truncated to meet AWS 64-character limits while preserving uniqueness.
