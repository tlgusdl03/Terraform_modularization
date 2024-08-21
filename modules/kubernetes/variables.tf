variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "region" {
  description = "Region where the EKS cluster is located"
  type        = string
}

variable "alb_image_repository" {
  description = "The repository for the AWS Load Balancer Controller image"
  type        = string
}

variable "lb_controller_service_account_name" {
  description = "Service account name for the AWS Load Balancer Controller"
  type        = string
}

variable "lb_controller_role_arn" {
  description = "IAM Role ARN for the AWS Load Balancer Controller"
  type        = string
}

variable "dependency" {
  description = "Dependencies for the Helm release"
  type        = any
}

variable "environment" {
  description = "settings deployment environment (ex.dev, prod)"
  type = string
}
