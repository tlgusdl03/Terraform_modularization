variable "redis_subnet_group_name" {
  description = "The name of the Redis subnet group"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs to use for the Redis subnet group"
  type        = list(string)
}

variable "redis_security_group_name" {
  description = "The name of the Redis security group"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where Redis will be deployed"
  type        = string
}

variable "eks_node_security_group_id" {
  description = "The security group ID of the EKS node"
  type        = string
}

variable "redis_replication_group_id" {
  description = "The ID of the Redis replication group"
  type        = string
}

variable "redis_description" {
  description = "The description of the Redis replication group"
  type        = string
}

variable "redis_engine_version" {
  description = "The Redis engine version"
  type        = string
  default     = "7.1"
}

variable "redis_node_type" {
  description = "The instance type for the Redis cluster"
  type        = string
  default     = "cache.t2.micro"
}

variable "redis_parameter_group_name" {
  description = "The Redis parameter group name"
  type        = string
  default     = "default.redis7.cluster.on"
}

variable "redis_automatic_failover_enabled" {
  description = "Whether to enable automatic failover for the Redis replication group"
  type        = bool
  default     = true
}

variable "redis_replicas_per_node_group" {
  description = "The number of replicas per node group"
  type        = number
  default     = 1
}

variable "redis_preferred_cache_cluster_azs" {
  description = "The preferred availability zones for the Redis cluster"
  type        = list(string)
}
