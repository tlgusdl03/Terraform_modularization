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

