# output "bastion_instance_id" {
#   description = "The ID of the Bastion EC2 instance."
#   value       = module.ec2_cli-primary.instance_id
# }
#
# output "bastion_public_ip" {
#   description = "The public IP of the Bastion EC2 instance."
#   value       = module.ec2_cli-primary.public_ip
# }
#
# output "ec2cli_role_name" {
#   description = "The name of the EC2 CLI IAM role"
#   value       = module.iam.ec2cli_role_name
# }
#
# output "lb_controller_policy_name" {
#   description = "The name of the AWS Load Balancer Controller IAM policy"
#   value       = module.iam.lb_controller_policy_name
# }
#
# output "eks_cluster_name" {
#   description = "The name of the EKS cluster"
#   value       = module.eks_cluster.eks_cluster_name
# }
#
# output "eks_cluster_endpoint" {
#   description = "The endpoint of the EKS cluster"
#   value       = module.eks_cluster.eks_cluster_endpoint
# }
#
