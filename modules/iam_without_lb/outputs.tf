################################################################################
# Outputs for IAM Module
################################################################################
output "ecom-role-ec2cli_name" {
  description = "The name of the EC2 CLI IAM role"
  value       = aws_iam_role.ecom-role-ec2cli.name
}


