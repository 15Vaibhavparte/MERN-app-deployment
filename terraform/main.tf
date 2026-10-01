
module "eks" {
  source = "/home/lenovo/terraform_demo/terraform-MERN/terraform/modules/eks"

  
  cluster-name               = var.cluster-name
  private_subnet_ids         = module.vpc.private_subnet_ids
  eks_cluster_sg_id          = module.vpc.eks_cluster_sg_id
  cluster-version            = var.cluster-version
  ondemand_instance_types    = var.ondemand_instance_types
  desired_capacity_on_demand = var.desired_capacity_on_demand
  min_capacity_on_demand     = var.min_capacity_on_demand
  max_capacity_on_demand     = var.max_capacity_on_demand
  
  spot_instance_types        = var.spot_instance_types
  desired_capacity_spot      = var.desired_capacity_spot
  min_capacity_spot          = var.min_capacity_spot
  max_capacity_spot          = var.max_capacity_spot
  
  addons = var.addons
}