# modules/rds_secondary/main.tf
data "aws_subnets" "secondary_aurora_subgroup" {
  filter {
    name = "vpc-id"
    values = [var.vpc_id]
  }
}

module "aurora_secondary" {
  source  = "terraform-aws-modules/rds-aurora/aws"

  name                      = var.name
#   database_name             = var.database_name
  engine                    = var.engine
  engine_version            = var.engine_version
#   master_username           = var.master_username
  global_cluster_identifier = var.global_cluster_identifier
  instance_class            = var.instance_class
  instances                 = var.instances
  kms_key_id = var.secondary_kms_key_id
  vpc_id               = var.vpc_id
  db_subnet_group_name = aws_db_subnet_group.secondary_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  availability_zones = var.secondary_azs

  manage_master_user_password = false
#   master_password = var.secondary_master_password

  skip_final_snapshot = var.skip_final_snapshot

  tags                = var.tags

  depends_on = [aws_db_subnet_group.secondary_db_subnet_group, aws_security_group.rds_sg]

  enable_local_write_forwarding = true
  apply_immediately = true
}

# DB Subnet Group 생성
resource "aws_db_subnet_group" "secondary_db_subnet_group" {
  name       = "secondary-prod-db-subnet-group"
  subnet_ids = data.aws_subnets.secondary_aurora_subgroup.ids  # 가져온 서브넷 ID 목록 사용

  tags = {
    Name = "secondary-prod-db-subnet-group"
  }
}

# RDS 보안 그룹 생성
resource "aws_security_group" "rds_sg" {
  name        = var.security_group_name
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks = var.security_group_rules
#     security_groups = var.node_security_group_ids # 이 부분이 문제가 되는 것 같음
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

# IAM Role 설정 (DB Proxy에서 Secrets Manager에 접근할 수 있도록 설정)
resource "aws_iam_role" "db_proxy_role" {
  name = "secondary-db-proxy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "rds.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role Policy 설정 (Secrets Manager 접근 권한)
resource "aws_iam_role_policy" "db_proxy_policy" {
  name   = "secondary-db-proxy-policy"
  role   = aws_iam_role.db_proxy_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Effect   = "Allow",
        Resource = aws_secretsmanager_secret.db_credentials_secret.arn
      }
    ]
  })
}

# Secrets Manager에 DB 자격 증명 저장
resource "aws_secretsmanager_secret" "db_credentials_secret" {
  name = format("secondary-db-credentials-%s", formatdate("YYYYMMDDHHmmss", timestamp()))
}

resource "aws_secretsmanager_secret_version" "db_credentials_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_credentials_secret.id
  secret_string = jsonencode({
    username = "${var.master_username}",
    password = "${var.master_password}"
  })
}

# RDS DB Proxy 생성
resource "aws_db_proxy" "aurora_proxy" {
  name                   = "secondary-db-proxy"
  debug_logging          = false
  engine_family          = "MYSQL"  # 데이터베이스 엔진에 맞춰 설정 (MYSQL, POSTGRESQL 등)
  idle_client_timeout    = 1800     # 비활성 클라이언트 타임아웃 (초 단위)
  require_tls            = true     # TLS 연결 강제

  role_arn               = aws_iam_role.db_proxy_role.arn
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  vpc_subnet_ids         = data.aws_subnets.secondary_aurora_subgroup.ids

  auth {
    auth_scheme = "SECRETS"
    description = "DB credentials from Secrets Manager"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.db_credentials_secret.arn
  }

  tags = {
    Name = "secondary-db-proxy"
  }
}

resource "aws_db_proxy_target" "example" {
  db_proxy_name          = aws_db_proxy.aurora_proxy.name
  target_group_name      = "default"
  db_cluster_identifier = module.aurora_secondary.cluster_id
}