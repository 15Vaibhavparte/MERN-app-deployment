


env                   = "dev"
vpc-cidr-block        = "10.16.0.0/16"
region               = "ap-south-1"
vpc-name              = "mern-vpc"
igw-name              = "mern-igw"
pub-subnet-count      = 3
pub-cidr-block        = ["10.16.0.0/20", "10.16.16.0/20", "10.16.32.0/20"]
pub-availability-zone = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
pub-sub-name          = "subnet-public"
pri-subnet-count      = 3
pri-cidr-block        = ["10.16.128.0/20", "10.16.144.0/20", "10.16.160.0/20"]
pri-availability-zone = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
pri-sub-name          = "subnet-private"
public-rt-name        = "public-route-table"
private-rt-name       = "private-route-table"
eip-name              = "elasticip-ngw"
ngw-name              = "ngw"
eks-sg                = "eks-sg"

# EKS Compute Variables
cluster-version            = "1.36" 
cluster-name               = "eks-mern-cluster"
ondemand_instance_types    = ["t3.small"]
desired_capacity_on_demand = 1      # Converted to numbers from strings
min_capacity_on_demand     = 1
max_capacity_on_demand     = 5

spot_instance_types        = ["c5a.large", "c5a.xlarge", "m5a.large", "m5a.xlarge", "c5.large", "m5.large", "t3a.large", "t3a.xlarge", "t3a.medium"]
desired_capacity_spot      = 1
min_capacity_spot          = 1
max_capacity_spot          = 10

# Addon versions must match the EKS cluster version 
addons = [
  {
    name    = "vpc-cni",
    version = "v1.23.2-eksbuild.1"
  },
  {
    name    = "coredns"
    version = "v1.14.6-eksbuild.4"
  },
  {
    name    = "kube-proxy",
    version = "v1.36.0-eksbuild.25" # Matches the 1.36 cluster version
  },
  {
    name    = "aws-ebs-csi-driver",
    version = "v1.66.0-eksbuild.1"
  }
]