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
  default     = true
  description = "Specifies whether the storage is encrypted"
}

variable "primary_vpc_id" {
  description = "Specifies whether the storage is encrypted"
  type = string
}

variable "primary_vpc_database_subnet_group_name" {
  description = "used primary vpc subnet group"
  type = any
}

variable "primary_vpc_private_subnets_cidr_blocks" {
  description = "using to set ingress of sg for primary"
  type = any
}

variable "secondary_vpc_id" {
  type = string
}

variable "secondary_vpc_database_subnet_group_name" {
  type = any
}

variable "secondary_vpc_private_subnets_cidr_blocks" {
  type = any
}

variable "node_security_group_ids" {
  type = any
}

variable "primary_azs" {
  type = any
}

variable "secondary_azs" {
  type = any
}