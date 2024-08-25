################################################################################
# VPC
################################################################################
module "vpc" {
  # for_each = { for idx, az in var.azs : idx => az }

  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.vpc_cidr

  azs             = var.azs
  # public_subnets: CIDR 블록 /27 크기 (32 IP)
  public_subnets = var.public_subnets_cidr

  # private_subnets: CIDR 블록 /26 크기 (64 IP)
  private_subnets = var.private_subnets_cidr

  # db_subnets: CIDR 블록 /27 크기 (32 IP)
  intra_subnets = var.database_subnets_cidr

  enable_nat_gateway = true
  one_nat_gateway_per_az = true

  public_subnet_tags = {
    "Name" = "${var.name}-public-subnet"  # 숫자 추가
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "Name" = "${var.name}-private-subnet"  # 숫자 추가
    "kubernetes.io/role/internal-elb" = 1
    "karpenter.sh/discovery" = var.name
  }

  intra_subnet_tags = {
    "Name" = "${var.name}-db-subnet"  # 숫자 추가
  }
  tags = var.tags
}

resource "aws_security_group" "ecr_endpoint_sg" {
  name        = var.ecr_endpoint_sg_name
  description = "Security group for ECR endpoint"
  vpc_id      = module.vpc.vpc_id
}

resource "aws_security_group_rule" "allow_https_endpoint" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecr_endpoint_sg.id
  to_port           = 443
  type              = "ingress"
  description       = "Allow HTTPS ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_https_egress" {
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ecr_endpoint_sg.id
  to_port           = 443
  type              = "egress"
  description       = "Allow HTTPS egress"
  cidr_blocks       = ["0.0.0.0/16"]
}

resource "aws_vpc_endpoint" "ecr_endpoint" {
  vpc_id            = module.vpc.vpc_id
  service_name      = var.ecr_service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.ecr_endpoint_sg.id
  ]

  private_dns_enabled = true
  subnet_ids          = var.ecr_endpoint_subnet_ids
}
