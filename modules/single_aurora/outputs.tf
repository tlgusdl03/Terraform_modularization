output "rds_endpoint" {
  description = "The RDS cluster endpoint"
  value       = aws_rds_cluster.aurora_mysql.endpoint
}
