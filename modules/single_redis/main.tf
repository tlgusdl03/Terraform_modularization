# Elasticache Subnet Group 생성
resource "aws_elasticache_subnet_group" "redis" {
  name       = var.subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = "redis"
  }
}

# Redis 보안 그룹 생성
resource "aws_security_group" "redis_sg" {
  name        = var.security_group_name
  description = "Security group for Redis"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.node_security_group_ids
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

# Redis Replication Group 생성
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = var.replication_group_id
  description                   = var.description
  engine                        = "redis"
  engine_version                = var.engine_version
  node_type                     = var.node_type
  parameter_group_name          = var.parameter_group_name
  port                          = var.port
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  security_group_ids            = [aws_security_group.redis_sg.id]
  automatic_failover_enabled    = var.automatic_failover_enabled
  replicas_per_node_group       = var.replicas_per_node_group
  preferred_cache_cluster_azs   = var.preferred_cache_cluster_azs

  tags = {
    Name = var.replication_group_name
  }
}
