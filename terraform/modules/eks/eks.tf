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
    endpoint_public_access  = true
    security_group_ids      = [var.eks_cluster_sg_id]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]
}

# Fetch the cluster's OIDC certificate thumbprint


# Register the OIDC provider with AWS IAM
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}



resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.2" # Pin a specific chart version for consistency

  # Pass configuration values to the Helm chart
  set = [
    {
      name  = "clusterName"
      value = aws_eks_cluster.eks.name
    },
    {
      name  = "region"
      value = var.region
    },
    {
      name  = "vpcId"
      value = var.vpc_id
    },
    {
      name  = "serviceAccount.create"
      value = "false"
    },
    {
      name  = "serviceAccount.name"
      value = "aws-load-balancer-controller"
    }
  ]


  depends_on = [
    module.alb_controller_irsa,
    aws_eks_cluster.eks
  ]
}

module "alb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.0"

  name = "AmazonEKSLoadBalancerControllerRole"

  # This tells the module to attach the pre-defined ALB Controller policy
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
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
  addon_version = try(each.value.version, null) 

  service_account_role_arn = (
    each.value.name == "aws-ebs-csi-driver"
    ? aws_iam_role.ebs_csi_driver_role.arn
    : null
  )

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
     aws_iam_role_policy_attachment.ebs_csi_driver_policy,
    aws_eks_node_group.ondemand,
    aws_eks_node_group.spot
  ]


}


