# modules/rds_primary/main.tf
module "aurora_primary" {
  source  = "terraform-aws-modules/rds/aws"
  version = var.module_version

  name                      = var.name
  database_name             = var.database_name
  engine                    = var.engine
  engine_version            = var.engine_version
  master_username           = var.master_username
  global_cluster_identifier = var.global_cluster_identifier
  instance_class            = var.instance_class
  instances                 = var.instances

  vpc_id               = var.vpc_id
  db_subnet_group_name = var.db_subnet_group_name
  security_group_rules = var.security_group_rules

  skip_final_snapshot = var.skip_final_snapshot
  tags                = var.tags
}

