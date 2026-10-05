


# 1. Dynamically fetch available Availability Zones in our region
data "aws_availability_zones" "available" {
  state = "available"
}

# 2. Fetch the EKS cluster's OIDC certificate thumbprint
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

# 3. Compile the Trust Policy for the EKS Control Plane
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


# 4. Compile the Trust Policy for the EBS CSI Driver IRSA
# The Trust Policy allowing the Kubernetes ServiceAccount to assume this role
data "aws_iam_policy_document" "ebs_csi_trust_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

# # Fetch cluster details
data "aws_eks_cluster" "cluster" {
  name = var.cluster-name 
  depends_on = [aws_eks_cluster.eks]
}

# Configure the Helm provider explicitly
provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)

    # Use exec to get a fresh token using the AWS CLI
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    }
  }
}