variable "key_name" {
  description = "The name of the key pair."
  type        = string
}

variable "pem_location" {
  description = "The location to store the private key file."
  type        = string
}

variable "sg_name" {
  description = "The name of the security group."
  type        = string
}

variable "sg_description" {
  description = "Description of the security group."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group will be created."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The type of instance to create."
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID for the EC2 instance."
  type        = string
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile to attach to the EC2 instance."
  type        = string
}

variable "iam_role_name" {
  description = "The name of the IAM role to attach to the EC2 instance."
  type        = string
}

variable "user_data" {
  description = "The user data script for EC2 initialization."
  type        = string
}

variable "instance_name" {
  description = "The name tag for the EC2 instance."
  type        = string
}

variable "iam_instance_profile_role" {
  description = "The role for iam_instance_profile"
  type = string
}