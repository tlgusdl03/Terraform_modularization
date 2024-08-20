output "redis_endpoint" {
  description = "The Redis primary endpoint address"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}
