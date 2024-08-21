################################################################################
# EC2 CLI IAM Role
################################################################################
resource "aws_iam_role" "ecom-role-ec2cli" {
  name = var.ec2cli_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = var.ec2cli_managed_policy_arns
}

################################################################################
# AWS Load Balancer Controller IAM Role Policy
################################################################################
data "http" "iam_policy" {
  url = var.lb_controller_policy_url
}

resource "aws_iam_role_policy" "eks_controller_policy" {
  name_prefix = var.lb_controller_policy_name_prefix
  role        = var.lb_controller_role_name
  policy      = data.http.iam_policy.response_body
}
