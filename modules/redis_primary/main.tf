# create primary elasticache
module "elasticache_primary" {
  source = "terraform-aws-modules/elasticache/aws"

  replication_group_id                    = "ecom-redis-global-replication-group"
  create_primary_global_replication_group = true

  engine_version = "7.1"
  node_type      = "cache.m7g.medium"

  # Security group
  vpc_id = module.vpc.vpc_id
  security_group_rules = {
    ingress_vpc = {
      # Default type is `ingress`
      # Default port is based on the default engine port
      description = "VPC traffic"
      cidr_ipv4   = module.vpc.vpc_cidr_block
    }
  }

  # Subnet Group
  subnet_ids = module.vpc.database_subnets

  # Parameter Group
  create_parameter_group = true
  parameter_group_family = "redis7"

  # Subnet Group
  subnet_ids = module.vpc.database_subnets

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name = "ecom-elasticache-primary"
  }
}

module "elasticache_secondary" {
  source = "terraform-aws-modules/elasticache/aws"

  providers = {
    region = "us-east-1"
  }

  replication_group_id        = "ecom-redis-global-replication-group"
  global_replication_group_id = "ecom-redis-global-replication-group"

  # Security group
  vpc_id = module.vpc_secondary.vpc_id
  security_group_rules = {
    ingress_vpc = {
      # Default type is `ingress`
      # Default port is based on the default engine port
      description = "VPC traffic"
      cidr_ipv4   = module.vpc_secondary.vpc_cidr_block
    }
  }

  # Subnet Group
  subnet_ids = module.vpc_secondary.database_subnets

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Name = "ecom-elasticache-secondary"
  }
}
