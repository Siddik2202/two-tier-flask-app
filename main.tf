# main.tf
provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr = "10.0.0.0/16"
  azs      = ["ap-south-1a", "ap-south-1b"]
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = "my-eks-cluster"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
}