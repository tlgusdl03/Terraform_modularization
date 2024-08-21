# modules/rds_secondary/outputs.tf
output "rds_secondary_id" {
  value = module.aurora_secondary.db_instance_ids
}
