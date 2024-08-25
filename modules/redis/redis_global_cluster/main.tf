provider "aws" {
  alias = "primary"
  region = "ap-southeast-2"
}

provider "aws" {
  alias = "secondary"
  region = "ap-northeast-1"
}

resource "aws_elasticache_global_replication_group" "example" {
  global_replication_group_id_suffix = "example"
  primary_replication_group_id       = aws_elasticache_replication_group.redis_primary.id
}
###########################################################################################
# create Primary
###########################################################################################
# Elasticache Subnet Group 생성
resource "aws_elasticache_subnet_group" "primary_redis-subgroup" {
  name       = var.primary_redis_subnet_group_name
  subnet_ids = var.primary_subnet_ids

  tags = {
    Name = "${var.primary_redis_security_group_name}"
  }
}

# Redis 보안 그룹 생성
resource "aws_security_group" "primary_redis_sg" {
  name        = var.primary_redis_security_group_name
  description = "Security group for Redis"
  vpc_id      = var.primary_vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.primary_redis_security_group_name
  }
}

resource "aws_elasticache_replication_group" "redis_primary" {
  replication_group_id          = var.primary_redis_replication_group_id
  description                   = var.primary_redis_replication_group_id
  engine                        = "redis"
  engine_version                = var.redis_engine_version
  node_type                     = var.redis_node_type
  parameter_group_name          = var.primary_redis_parameter_group_name
  subnet_group_name             = aws_elasticache_subnet_group.primary_redis-subgroup.name
  security_group_ids            = [aws_security_group.primary_redis_sg.id]
  automatic_failover_enabled    = var.redis_automatic_failover_enabled
  replicas_per_node_group       = var.redis_replicas_per_node_group
  preferred_cache_cluster_azs   = var.redis_primary_preferred_cache_cluster_azs

  tags = {
    Name = var.primary_redis_replication_group_id
  }
}
####################################################################################################
# crate Secondary
####################################################################################################
# Elasticache Subnet Group 생성
resource "aws_elasticache_subnet_group" "secondary-redis-subgroup" {
  provider = aws.secondary
  name       = var.secondary_redis_subnet_group_name
  subnet_ids = var.secondary_subnet_ids

  tags = {
    Name = "${var.secondary_redis_subnet_group_name}"
  }
}

# Redis 보안 그룹 생성
resource "aws_security_group" "secondary-redis_sg" {
  provider = aws.secondary
  name        = var.secondary_redis_security_group_name
  description = "Security group for Redis"
  vpc_id      = var.secondary_vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
#     security_groups = var.eks_node_security_group_id
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.secondary_redis_security_group_name
  }
}

resource "aws_elasticache_replication_group" "redis_secondary" {

  provider = aws.secondary

  global_replication_group_id = aws_elasticache_global_replication_group.example.global_replication_group_id

#   num_cache_clusters = 1
  replication_group_id          = var.secondary_redis_replication_group_id
  description                   = var.secondary_redis_replication_group_id
#   engine                        = "redis"
#   engine_version                = var.redis_engine_version
#   node_type                     = var.redis_node_type
#   parameter_group_name          = var.secondary_redis_parameter_group_name
  subnet_group_name             = aws_elasticache_subnet_group.secondary-redis-subgroup.name
  security_group_ids            = [aws_security_group.secondary-redis_sg.id]
  automatic_failover_enabled    = var.redis_automatic_failover_enabled
  replicas_per_node_group       = var.redis_replicas_per_node_group
  preferred_cache_cluster_azs   = var.redis_secondary_preferred_cache_cluster_azs

  tags = {
    Name = var.secondary_redis_replication_group_id
  }
}


















