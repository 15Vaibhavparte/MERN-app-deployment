


# 1. Dynamically fetch available Availability Zones in our region
data "aws_availability_zones" "available" {
  state = "available"
}

# 2. Compile the Trust Policy for the EKS Control Plane
data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# 3. Compile the Trust Policy for the EC2 Worker Nodes
data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}