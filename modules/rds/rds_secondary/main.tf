# modules/rds_secondary/main.tf
module "aurora_secondary" {
  source  = "terraform-aws-modules/rds/aws"
  version = var.module_version

  providers = { aws = var.aws_provider }

  is_primary_cluster = false

  name                      = var.name
  engine                    = var.engine
  engine_version            = var.engine_version
  global_cluster_identifier = var.global_cluster_identifier
  source_region             = var.source_region
  instance_class            = var.instance_class
  instances                 = var.instances

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet_group_name
  security_group_rules = var.security_group_rules

  skip_final_snapshot = var.skip_final_snapshot
  tags                = var.tags
}


