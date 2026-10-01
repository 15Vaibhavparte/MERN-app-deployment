output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets where EKS worker nodes run."
  value       = module.vpc.private_subnet_ids
}

output "eks_cluster_sg_id" {
  description = "ID of the Jump Server security group."
  value       = module.vpc.eks_cluster_sg_id
}