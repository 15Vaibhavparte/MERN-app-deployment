
module "eks" {
  source = "./modules/eks"

  cluster-name               = var.cluster_name
  env                        = var.env
  region                     = var.region
  vpc_id                     = module.vpc.vpc_id
  enable_alb_controller      = var.enable_alb_controller
  private_subnet_ids         = module.vpc.private_subnet_ids
  eks_cluster_sg_id          = module.vpc.eks_cluster_sg_id
  cluster-version            = var.cluster_version

  # EKS Node Group Configuration
  ondemand_instance_types    = var.ondemand_instance_types
  desired_capacity_on_demand = var.desired_capacity_on_demand
  min_capacity_on_demand     = var.min_capacity_on_demand
  max_capacity_on_demand     = var.max_capacity_on_demand
  
  # Spot Node Group Configuration
  spot_instance_types        = var.spot_instance_types
  desired_capacity_spot      = var.desired_capacity_spot
  min_capacity_spot          = var.min_capacity_spot
  max_capacity_spot          = var.max_capacity_spot
  
  # Addons Configuration
  addons = var.addons


}

