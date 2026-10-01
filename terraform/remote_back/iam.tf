# Generate the exact IAM permissions required for Terraform 1.10+ Native S3 Locking
data "aws_iam_policy_document" "terraform_state_access" {
  statement {
    sid       = "AllowListBucket"
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.terraform_state.arn]
  }

  statement {
    sid    = "AllowStateReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    # Restrict to the specific path where the EKS state will be stored
    resources = ["${aws_s3_bucket.terraform_state.arn}/eks/terraform.tfstate"]
  }

  statement {
    sid    = "AllowLockFileManagement"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    # The lock file is created with the .tflock extension.
    # DeleteObject is ONLY granted to the lock file, NOT the state file.
    resources = ["${aws_s3_bucket.terraform_state.arn}/eks/terraform.tfstate.tflock"]
  }
}

# Create the actual IAM Policy in AWS
resource "aws_iam_policy" "terraform_state_management" {
  name        = "TerraformStateManagementPolicy"
  description = "Allows Terraform to read/write state and manage S3 native locks"
  policy      = data.aws_iam_policy_document.terraform_state_access.json
}

output "terraform_execution_policy_arn" {
  description = "Attach this policy to the IAM User or Role running Terraform."
  value       = aws_iam_policy.terraform_state_management.arn
}

data "aws_iam_policy_document" "enforce_tls" {
  statement {
    sid    = "EnforceTLSRequestsOnly"
    effect = "Deny"
    
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    
    actions   = ["s3:*"]
    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*"
    ]
    
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "strict_transport" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.enforce_tls.json
}