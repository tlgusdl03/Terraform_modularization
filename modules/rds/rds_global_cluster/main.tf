# modules/rds_global_cluster/main.tf
resource "aws_rds_global_cluster" "this" {
  global_cluster_identifier = var.global_cluster_identifier
  engine                    = var.engine
  engine_version            = var.engine_version
  database_name             = var.database_name
  storage_encrypted         = var.storage_encrypted
}




