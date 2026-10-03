env                = "dev"
public_subnet_cidr = "172.31.100.0/24" # must NOT overlap existing default VPC subnets
public_subnet_az   = "ap-south-1a"     # must be a valid AZ in your region
instance_type      = "t3.medium"
root_volume_size  = 25
root_volume_type  = "gp3"