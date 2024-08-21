variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the EKS cluster"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "additional_security_group_id" {
  description = "Additional security group ID for the EKS cluster"
  type        = string
}

variable "eks_node_group_node_min_size"{
  description = "EKS cluster 노드 그룹의 최소 노드 수"
  type = number
}

variable "eks_node_group_node_max_size"{
  description = "EKS cluster 노드 그룹의 최대 노드 수"
  type = number
}

variable "eks_node_group_node_desire_size"{
  description = "EKS cluster 노드 그룹의 desire 노드 수"
  type = number
}

variable "lb_controller_iam_role_name" {
  description = "lb_controller_iam_role의 이름을 정합니다"
  type = string
}