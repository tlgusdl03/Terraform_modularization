output "eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "The endpoint of the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "lb_controller_role_name" {
  description = "IAM Role name for Load Balancer Controller"
  value = module.lb_controller_role.iam_role_name
}

output "lb_controller_role_arn" {
  description = "IAM Role arn for Load Balancer Controller"
  value = module.lb_controller_role.iam_role_arn
}

output "node_security_group_id" {
  description = "ID of sg for EKS node"
  value = module.eks.node_security_group_id
}
