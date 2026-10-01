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

resource "aws_iam_role" "eks_nodes_role" {
  name = "${var.cluster-name}-nodegroup_role-${random_integer.random_suffix.result}"

  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

# Dynamically attach all required worker node policies
resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  ])

  policy_arn = each.value
  role       = aws_iam_role.eks_nodes_role.name
}