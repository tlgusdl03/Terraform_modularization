output "azs" {
  description = "The AZs of the VPC"
  value = module.vpc.azs
}
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
output "private_subnets" {
  description = "List of private subnets in the VPC"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "List of public subnets in the VPC"
  value       = module.vpc.public_subnets
}

output "database_subnets" {
  description = "List of Database subnets in the VPC"
  value = module.vpc.intra_subnets
}