# # #########################################################################################################
# # ## Terraform configurations (AWS)
# # #########################################################################################################
# # #variable "aws_access_key" {
# # #  type        = string
# # #  description = "AWS Access Key"
# # #}
# # #
# # #variable "aws_secret_key" {
# # #  type        = string
# # #  description = "AWS Secret Key"
# # #}
# # #
# # #variable "aws_session_token" {
# # #  type        = string
# # #  description = "AWS Session Token"
# # #}
# #
# # variable "pem_location" {
# #   type    = string
# #   default = "."
# # }
# #
# # variable "terraform_aws_profile" {
# #   type = string
# #   default = "jinsu"
# # }
# #
# # variable "terraform_workspace-name" {
# #   type = string
# #   default = "jinsu"
# # }
# #
# # variable "aws_region" {
# #   type = string
# #   default = "ap-northeast-2"
# # }
# #
# # variable "cluster-name" {
# #   default = "cluster"
# # }
# #
# # variable "cluster-version" {
# #   default = "1.30"
# # }
# #
# # locals {
# #     region = "ap-northeast-2"
# # }
# variable "public_subnets_cidr" {
#   description = "List of public_subnets_cidr"
#   type = list(string)
# }
#
# variable "private_subnets_cidr" {
#   description = "List of private_subnets_cidr"
#   type = list(string)
# }
#
# variable "database_subnets_cidr" {
#   description = "List of database_subnets_cidr"
#   type = list(string)
# }
#
# variable "pem_location" {
#   description = "The local path to store the key pair PEM file."
#   type        = string
# }
#
# variable "ec2cli_role_name" {
#   description = "Name for the EC2 CLI IAM role"
#   type        = string
# }
#
# variable "lb_controller_role_name" {
#   description = "IAM role name for the AWS Load Balancer Controller"
#   type        = string
# }
#
# variable "cluster_name" {
#   description = "Name of the EKS cluster"
#   type        = string
# }
#
# variable "cluster_version" {
#   description = "Version of the EKS cluster"
#   type        = string
# }
#
