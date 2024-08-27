provider "aws" {
  alias = "primary"
  region = "ap-northeast-2"
}

provider "aws" {
  alias = "secondary"
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

locals {
  name = "ex-${basename(path.cwd)}"
  tags = {
    Example    = local.name
    GithubRepo = "terraform-aws-rds-aurora"
    GithubOrg  = "terraform-aws-modules"
  }
}

#############################################################################
# Create Global Database
############################################################################
# modules/rds_global_cluster/main.tf
resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = var.global_cluster_identifier
  engine                    = var.engine
  engine_version            = var.engine_version
  database_name             = var.database_name
  storage_encrypted         = var.storage_encrypted
}

module "aurora_primary" {
  providers = {
    aws = aws.primary
  }
  source = "../rds_primary"

  name = "primarydatabase"
  #   database_name = aws_rds_global_cluster.this.database_name
  engine                    = aws_rds_global_cluster.this.engine
  engine_version            = aws_rds_global_cluster.this.engine_version
  master_username           = "admin"
  global_cluster_identifier = aws_rds_global_cluster.this.global_cluster_identifier
  instance_class            = "db.r5.large"
  instances                 = {for i in range(2) : i => {}}
  primary_kms_key_id        = aws_kms_key.primary.arn
  vpc_id                    = var.primary_vpc_id
  db_subnet_group_name      = var.primary_vpc_database_subnet_group_name
  security_group_rules = var.primary_vpc_private_subnets_cidr_blocks

  tags                    = local.tags
  primary_master_password = random_password.master.result


  master_password         = "admin"
  node_security_group_ids = var.node_security_group_ids
  security_group_name     = "primary-prod-ecom-sg-rds"

  primary_azs = var.primary_azs
}
module "aurora_secondary" {
  source = "../rds_secondary"

  providers = { aws = aws.secondary }
  name = "secondarydatabase"
#   database_name = aws_rds_global_cluster.this.database_name
  engine = aws_rds_global_cluster.this.engine
  engine_version            = aws_rds_global_cluster.this.engine_version
#   master_username           = "admin"
  global_cluster_identifier = aws_rds_global_cluster.this.global_cluster_identifier
  instance_class            = "db.r5.large"
  instances = { for i in range(2) : i => {}}
  vpc_id                    = var.secondary_vpc_id
  db_subnet_group_name      = var.secondary_vpc_database_subnet_group_name
  security_group_rules = var.secondary_vpc_private_subnets_cidr_blocks



  tags = local.tags
  secondary_kms_key_id      = aws_kms_key.secondary.arn
#   secondary_master_password = random_password.master.result
  source_region             = "ap-northeast-2"


  master_password         = random_password.master.result
  master_username         = "admin"
  node_security_group_ids = var.node_security_group_ids
  security_group_name     = "secondary-prod-ecom-sg-rds"


  secondary_azs = var.secondary_azs
}
##########################################################################
# Supporting Resources
##########################################################################
resource "random_password" "master" {
  length = 20
  special = false
}

data "aws_iam_policy_document" "rds" {
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root",
        data.aws_caller_identity.current.arn,
      ]
    }
  }
  statement {
    sid = "Allow use of the key"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]

    principals {
      type = "Service"
      identifiers = [
        "monitoring.rds.amazonaws.com",
        "rds.amazonaws.com",
      ]
    }
  }
}

resource "aws_kms_key" "primary" {
  provider = aws.primary
  policy = data.aws_iam_policy_document.rds.json
  tags   = local.tags
}

resource "aws_kms_key" "secondary" {
  provider = aws.secondary

  policy = data.aws_iam_policy_document.rds.json
  tags   = local.tags
}
