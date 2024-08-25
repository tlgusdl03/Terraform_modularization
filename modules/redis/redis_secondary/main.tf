# Elasticache Subnet Group 생성
resource "aws_elasticache_subnet_group" "redis" {
  name       = var.redis_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.redis_subnet_group_name}"
  }
}

# Redis 보안 그룹 생성
resource "aws_security_group" "redis_sg" {
  name        = var.redis_security_group_name
  description = "Security group for Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.eks_node_security_group_id
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.redis_security_group_name
  }
}

resource "aws_elasticache_replication_group" "redis" {

  provider = var.redis_other_provider

  global_replication_group_id = aws_elasticache_global_replication_group.example.global_replication_group_id

  num_cache_clusters = 1
  replication_group_id          = var.redis_replication_group_id
  description                   = var.redis_replication_group_id
  engine                        = "redis"
  engine_version                = var.redis_engine_version
  node_type                     = var.redis_node_type
  parameter_group_name          = var.redis_parameter_group_name
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  security_group_ids            = [aws_security_group.redis_sg.id]
  automatic_failover_enabled    = var.redis_automatic_failover_enabled
  replicas_per_node_group       = var.redis_replicas_per_node_group
  preferred_cache_cluster_azs   = var.redis_preferred_cache_cluster_azs

  tags = {
    Name = var.redis_replication_group_id
  }
}


















