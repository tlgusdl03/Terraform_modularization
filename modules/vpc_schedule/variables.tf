variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnets_cidr" {
  description = "List of public_subnets_cidr"
  type = list(string)
}

variable "private_subnets_cidr" {
  description = "List of private_subnets_cidr"
  type = list(string)
}

variable "database_subnets_cidr" {
  description = "List of database_subnets_cidr"
  type = list(string)
}

variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
}

variable "ecr_endpoint_sg_name" {
  description = "Name of the security group for ECR endpoint"
  type        = string
}

variable "ecr_service_name" {
  description = "ECR service name for the VPC endpoint"
  type        = string
}

variable "ecr_endpoint_subnet_ids" {
  description = "ECR endpoint가 위치할 서브넷"
  type = list(string)
}
