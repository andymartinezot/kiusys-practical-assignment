output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "rds_endpoint" {
  value = module.rds.cluster_endpoint
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}