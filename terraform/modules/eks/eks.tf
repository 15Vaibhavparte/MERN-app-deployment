resource "aws_eks_cluster" "eks" {
  name = var.cluster-name

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster-iam-role.arn
  version  = var.cluster-version 

  vpc_config {
    subnet_ids = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = false
    security_group_ids      = [var.eks_cluster_sg_id]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

resource "aws_eks_node_group" "ondemand" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster-name}-ondemand-nodes"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  
  # Deploying into the private subnets you created previously                                             
  subnet_ids      = var.private_subnet_ids
  
  capacity_type   = "ON_DEMAND"
  instance_types  = var.ondemand_instance_types

  scaling_config {
    desired_size = var.desired_capacity_on_demand
    min_size     = var.min_capacity_on_demand
    max_size     = var.max_capacity_on_demand
  }

  labels = {
    type = "ondemand"
  }

  # Ensure IAM permissions are fully attached before creating the nodes,
  # otherwise EKS will fail to launch the EC2 instances.
  depends_on = [
    aws_iam_role_policy_attachment.node_policies
  ]
}

resource "aws_eks_node_group" "spot" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster-name}-spot"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = var.private_subnet_ids
  capacity_type   = "SPOT"
  instance_types  = var.spot_instance_types

  scaling_config {
    desired_size = var.desired_capacity_spot
    min_size     = var.min_capacity_spot
    max_size     = var.max_capacity_spot
  }

  labels = { lifecycle = "spot" }
  depends_on = [aws_iam_role_policy_attachment.node_policies]
}

resource "aws_eks_addon" "addons" {
  for_each      = { for addon in var.addons : addon.name => addon }
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = each.value.name
  addon_version = each.value.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.ondemand,
    aws_eks_node_group.spot
  ]
}