variable "security_group_name" {
  description = "The name of the security group for RDS"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC for RDS"
  type        = string
}

variable "node_security_group_ids" {
  description = "List of security group IDs for EKS nodes"
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "The name of the DB subnet group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS cluster"
  type        = list(string)
}

variable "cluster_identifier" {
  description = "The ID of the RDS cluster"
  type        = string
}

variable "engine" {
  description = "The database engine type"
  type        = string
}

variable "engine_version" {
  description = "The version of the database engine"
  type        = string
}

variable "master_username" {
  description = "The master username for the database"
  type        = string
}

variable "master_password" {
  description = "The master password for the database"
  type        = string
}

variable "database_name" {
  description = "The name of the default database"
  type        = string
}

variable "backup_retention_period" {
  description = "The backup retention period in days"
  type        = number
  default     = 1
}

variable "preferred_backup_window" {
  description = "The preferred backup window"
  type        = string
}

variable "storage_encrypted" {
  description = "Whether storage encryption is enabled"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot before deletion"
  type        = bool
  default     = true
}

variable "instance_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
}

variable "publicly_accessible" {
  description = "Whether the RDS instance should be publicly accessible"
  type        = bool
  default     = false
}
