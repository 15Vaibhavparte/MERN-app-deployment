


module "vpc" {
  source = "/home/lenovo/terraform_demo/terraform-MERN/modules/vpc" # Adjust path to your VPC module directory

  env          = var.env
  cluster-name = var.cluster-name
  vpc-name   = "${var.env}-${var.vpc-name}"
  cidr-block = var.vpc-cidr-block
  igw-name   = "${var.env}-${var.igw-name}"

  # Public Subnets
  pub-subnet-count      = var.pub-subnet-count
  pub-cidr-block        = var.pub-cidr-block
  pub-availability-zone = var.pub-availability-zone
  pub-sub-name          = "${var.env}-${var.pub-sub-name}"
  public-rt-name        = "${var.env}-${var.public-rt-name}"

  # Private Subnets
  pri-subnet-count      = var.pri-subnet-count
  pri-cidr-block        = var.pri-cidr-block
  pri-availability-zone = var.pri-availability-zone
  pri-sub-name          = "${var.env}-${var.pri-sub-name}"
  private-rt-name       = "${var.env}-${var.private-rt-name}"

  # NAT Gateway & Security
  eip-name = "${var.env}-${var.eip-name}"
  ngw-name = "${var.env}-${var.ngw-name}"
  eks-sg   = var.eks-sg
}