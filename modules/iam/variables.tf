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

variable "lb_controller_policy_url" {
  description = "URL of the IAM policy for AWS Load Balancer Controller"
  type        = string
}

variable "lb_controller_policy_name_prefix" {
  description = "Prefix for the AWS Load Balancer Controller IAM policy name"
  type        = string
}

variable "lb_controller_role_name" {
  description = "IAM role name for AWS Load Balancer Controller"
  type        = string
}
