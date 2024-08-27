
# modules/rds_primary/variables.tf
variable "name" {
  type        = string
  description = "The name of the RDS cluster"
}

variable "engine" {
  type        = string
  description = "The database engine (e.g., aurora-mysql)"
}

variable "engine_version" {
  type        = string
  description = "The version of the database engine"
}

variable "master_username" {
  type        = string
  description = "The master username for the database"
}

variable "master_password" {
  type = string
}

variable "global_cluster_identifier" {
  type        = string
  description = "The identifier for the global RDS cluster"
}

variable "instance_class" {
  type        = string
  description = "The instance class for the database instances"
}

variable "instances" {
  type        = map(any)
  description = "The number of instances to create"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC to deploy the RDS instances in"
}

variable "db_subnet_group_name" {
  type        = string
  description = "The DB subnet group name"
}

variable "security_group_rules" {
  type        = any
  description = "Security group rules for the RDS instances"
}

variable "skip_final_snapshot" {
  type        = bool
  default     = true
  description = "Skip the final snapshot upon deletion"
}

variable "tags" {
  type        = map(string)
  description = "Tags for the resources"
}

variable "primary_kms_key_id" {
  type = any
}

variable "primary_master_password" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "node_security_group_ids" {
  type = any
}

variable "primary_azs" {
  type = any
}