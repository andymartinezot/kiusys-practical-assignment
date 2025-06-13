
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

module "vpc" {
  source = "./modules/vpc"
  name   = "kiusys-vpc"
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "kiusys-cluster"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  public_subnets  = module.vpc.public_subnets
}

module "rds" {
  source          = "./modules/rds"
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  db_name         = "kiusysdb"
  db_username     = var.db_username
  db_password     = var.db_password
}