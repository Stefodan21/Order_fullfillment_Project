# Infrastructure Setup Guide

This directory contains Terraform configuration for deploying the Order Fulfillment infrastructure to AWS.

## Quick Start

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit `terraform.tfvars` with your configuration:**
   ```hcl
   deployer_principal_arn = "arn:aws:iam::YOUR_ACCOUNT_ID:user/YOUR_USERNAME"
   project_name = "order-fulfillment"
   environment = "dev"
   region = "us-east-1"
   ```

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

### "Invalid deployer_principal_arn"
Ensure the ARN follows the correct format:
- User: `arn:aws:iam::ACCOUNT_ID:user/USERNAME`
- Role: `arn:aws:iam::ACCOUNT_ID:role/ROLENAME`

### "Circular dependency" errors
This has been resolved in the current configuration using ArnLike patterns instead of direct resource references.

### Lambda function naming
Function names are automatically truncated to meet AWS 64-character limits while preserving uniqueness.
