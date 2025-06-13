module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = concat(var.public_subnets, var.private_subnets)
  vpc_id          = var.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      min_capacity     = 1
      max_capacity     = 5
      instance_types   = ["t3.medium"]
    }
  }
}