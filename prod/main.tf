provider "aws" {
  alias = "primary"
  region = "ap-northeast-2"
}

provider "aws" {
  alias = "secondary"
  region = "us-east-1"
}


# provider "helm" {
#   kubernetes {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#
#     exec {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       # This requires the awscli to be installed locally where Terraform is executed
#       args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#     }
#   }
# }

# provider "kubectl" {
#   apply_retry_count      = 5
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
#   load_config_file       = false
#
#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }
#
# data "aws_availability_zones" "available" {}
#
# locals {
#   name   = "main"
#   vpc_cidr = "10.0.0.0/16"
#   azs = [
#     data.aws_availability_zones.available.names[0], # 첫 번째 가용 영역
#     data.aws_availability_zones.available.names[2]  # 세 번째 가용 영역
#   ]
#
#   tags = {
#     Name    = local.name
#   }
# }


##############################################################################
# Create VPC
###############################################################################
module "vpc" {

  providers = {
    aws = aws.primary
  }

  source = "../modules/vpc"

  azs = ["ap-northeast-2a", "ap-northeast-2c"]
  ecr_endpoint_sg_name = "ecom-sg-ecrendpoint-primary"
  ecr_service_name     = "com.amazonaws.ap-northeast-2.ssm"
  name                 = "ecom-endpoint-ecr"
  tags = {
    Name = "ecom-endpoint-ecr"
  }
  vpc_cidr             = "10.0.0.0/24"

  # public_subnets: CIDR 블록 /27 크기 (32 IP)
  database_subnets_cidr = [
  "10.0.0.0/27",  # pub01: 10.0.0.0/27
  "10.0.0.32/27"   # pub02: 10.0.0.32/27
  ]
  # private_subnets: CIDR 블록 /26 크기 (64 IP)
  private_subnets_cidr = [
    "10.0.0.64/26",  # pri01: 10.0.0.64/26
    "10.0.0.128/26"   # pri02: 10.0.0.128/26
  ]
  # db_subnets: CIDR 블록 /27 크기 (32 IP)
  public_subnets_cidr = [
  "10.0.0.192/27",  # db-pri01: 10.0.0.192/27
  "10.0.0.224/27"   # db-pri02: 10.0.0.224/27
  ]
}
#########################################################################################
# Create ec2
########################################################################################
module "ec2" {
  source = "../modules/ec2"

  ami_id                    = "ami-0c2acfcb2ac4d02a0"
  iam_instance_profile_name = "ec2_cli_profile_allow_ssm"
  iam_instance_profile_role = module.iam.ecom-role-ec2cli_name
  iam_role_name             = "ecom-role-ec2cli"
  instance_name             = "ecom-ec2-cli"
  instance_type             = "t3.micro"
  key_name                  = "ecom-kp-cli"
  pem_location              = "."
  sg_description            = "ecom-sg-cli"
  sg_name                   = "ecom-sg-cli"
  subnet_id                 = module.vpc.private_subnets[0]
  user_data                 = file("${path.module}/user_data.sh")
  vpc_id                    = module.vpc.vpc_id
}
#################################################################################
# Create IAM
#################################################################################
module "iam" {
  source = "../modules/iam"

  ec2cli_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"]
  ec2cli_role_name                 = "ecom-role-ec2cli"
  lb_controller_policy_name_prefix = "AWSLoadBalancerControllerIAMPolicy"
  lb_controller_policy_url         = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.2/docs/install/iam_policy.json"
  lb_controller_role_name          = "lb-controller-role"
}
#####################################################################################
# Create EKS
#####################################################################################
module "eks" {
  source = "../modules/eks"

  additional_security_group_id = "ecom-sg-cli"
  cluster_name                 = "cluster"
  cluster_version              = "1.30"
  private_subnets = module.vpc.private_subnets
  vpc_id                       = module.vpc.vpc_id
}
#####################################################################################
# Create Kubernetes Helm
#####################################################################################
# module "kubernetes" {
#   source = "./modules/kubernetes"
#
#   alb_image_repository               = ""
#   cluster_name                       = ""
#   dependency                         = ""
#   lb_controller_role_arn             = ""
#   lb_controller_service_account_name = ""
#   region                             = ""
#   vpc_id                             = ""
# }