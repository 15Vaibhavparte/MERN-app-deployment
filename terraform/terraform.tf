
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {
  bucket         = "eks-mern-tf-state-bucket-37194"
  key            = "eks/terraform.tfstate"
  region         = "ap-south-1"
  use_lockfile = true
  encrypt        = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region

}

