################################################################################
# Outputs for IAM Module
################################################################################
output "ecom-role-ec2cli_name" {
  description = "The name of the EC2 CLI IAM role"
  value       = aws_iam_role.ecom-role-ec2cli.name
}

output "lb_controller_policy_name" {
  description = "The name of the AWS Load Balancer Controller IAM policy"
  value       = aws_iam_role_policy.eks_controller_policy.name
}

