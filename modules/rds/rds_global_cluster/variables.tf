# modules/rds_global_cluster/variables.tf
variable "global_cluster_identifier" {
  type        = string
  description = "The identifier for the global RDS cluster"
}

variable "engine" {
  type        = string
  description = "The database engine (e.g., aurora-mysql)"
}

variable "engine_version" {
  type        = string
  description = "The version of the database engine"
}

variable "database_name" {
  type        = string
  description = "The name of the database"
}

variable "storage_encrypted" {
  type        = bool
  default     = false
  description = "Specifies whether the storage is encrypted"
}