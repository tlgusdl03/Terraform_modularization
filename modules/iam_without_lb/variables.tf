################################################################################
# Variables for IAM Module
################################################################################
variable "ec2cli_role_name" {
  description = "Name of the IAM role for EC2 CLI"
  type        = string
}

variable "ec2cli_managed_policy_arns" {
  description = "List of managed policy ARNs for EC2 CLI role"
  type        = list(string)
}

