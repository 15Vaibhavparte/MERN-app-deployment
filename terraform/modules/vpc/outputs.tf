output "vpc_id" {
  description = "The ID of the VPC."
  value       = aws_vpc.vpc.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = aws_subnet.public-subnet[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets."
  value       = aws_subnet.private-subnet[*].id
}

output "eks_cluster_sg_id" {
  description = "ID of the EKS security group."
  value       = aws_security_group.eks-cluster-sg.id
}