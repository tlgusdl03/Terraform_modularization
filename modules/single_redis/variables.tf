variable "subnet_group_name" {
  description = "The name of the ElastiCache subnet group"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the ElastiCache cluster"
  type        = list(string)
}

variable "security_group_name" {
  description = "The name of the security group for Redis"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC for Redis"
  type        = string
}

variable "node_security_group_ids" {
  description = "List of security group IDs for EKS nodes"
  type        = list(string)
}

variable "replication_group_id" {
  description = "The ID of the Redis replication group"
  type        = string
}

variable "description" {
  description = "Description of the Redis replication group"
  type        = string
}

variable "engine_version" {
  description = "The version of the Redis engine"
  type        = string
  default     = "7.1"
}

variable "node_type" {
  description = "The node type for Redis"
  type        = string
  default     = "cache.t2.micro"
}

variable "parameter_group_name" {
  description = "The name of the Redis parameter group"
  type        = string
  default     = "default.redis7.cluster.on"
}

variable "port" {
  description = "The port for Redis"
  type        = number
  default     = 6379
}

variable "automatic_failover_enabled" {
  description = "Whether automatic failover is enabled"
  type        = bool
  default     = true
}

variable "replicas_per_node_group" {
  description = "Number of replicas per node group"
  type        = number
  default     = 1
}

variable "preferred_cache_cluster_azs" {
  description = "List of preferred availability zones for Redis"
  type        = list(string)
}

variable "replication_group_name" {
  description = "The name of the Redis replication group"
  type        = string
}
