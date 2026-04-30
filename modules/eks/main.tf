module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.30"

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  # ADD THESE THREE LINES:
  cluster_endpoint_public_access           = true  # Makes the API reachable from internet
  enable_cluster_creator_admin_permissions = true  # Gives your IAM user admin rights
  authentication_mode                      = "API_AND_CONFIG_MAP"

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2_x86_64"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 2
      desired_size   = 1
    }
  }
}