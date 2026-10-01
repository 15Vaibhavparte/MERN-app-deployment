

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
}

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.bucket-name}-${random_integer.suffix.result}"


# Prevent accidental destruction of the S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Terraform State Backend"
    Environment = "Management"
  }
}


resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# CRITICAL: Completely locks down the bucket from the internet.
resource "aws_s3_bucket_public_access_block" "state_public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

output "terraform_state_bucket_name" {
  description = "Copy this value into the 'bucket' argument of your EKS backend blocks."
  value       = aws_s3_bucket.terraform_state.bucket
}

