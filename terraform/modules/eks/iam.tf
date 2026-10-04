resource "random_integer" "random_suffix" {
  min = 1000
  max = 9999
}


resource "aws_iam_role" "cluster-iam-role" {
  name = "${var.cluster-name}-role-${random_integer.random_suffix.result}"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster-iam-role.name
}

resource "aws_eks_access_entry" "bms_user_access" {
  cluster_name  = aws_eks_cluster.eks.name # <-- IMPORTANT: Update "this" if your EKS cluster resource is named differently (e.g., aws_eks_cluster.eks.name)
  principal_arn = "arn:aws:iam::168266173985:user/bms-user"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "bms_user_admin" {
  cluster_name  = aws_eks_cluster.eks.name # <-- IMPORTANT: Update "this" here as well
  principal_arn = aws_eks_access_entry.bms_user_access.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  
  access_scope {
    type = "cluster"
  }
}


# ---------- Node Group IAM Role ----------

resource "aws_iam_role" "eks_nodes_role" {
  name = "${var.cluster-name}-nodegroup_role-${random_integer.random_suffix.result}"

  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

# Dynamically attach all required worker node policies
resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"    
  ])

  policy_arn = each.value
  role       = aws_iam_role.eks_nodes_role.name
}


# --------------------------------------------------- EBS CSI Driver IRSA -------------------------------------


# Create the Role
resource "aws_iam_role" "ebs_csi_driver_role" {
  name               = "${var.env}-ebs-csi-driver-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_trust_policy.json
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver_role.name
}

# --------------------------------------------------- ALB Controller IRSA -------------------------------------

resource "aws_iam_policy" "alb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM policy for AWS Load Balancer Controller"

  # Assumes your iam_policy.json file is in the same directory
  policy = var.alb_controller_policy_json_path
}