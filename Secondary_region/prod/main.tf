##################################################################################
# 컨벤션 룰 : <주 리전/보조 리전>-<환경>-<대분류>-<리소스 종류>-<설명>
##########################################################################
terraform {
  required_version = ">= 1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.61"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0"
    }
  }
}

provider "aws" {
  alias = "primary"
  region = "ap-southeast-2"
}

provider "aws" {
  alias = "secondary"
  region = "ap-northeast-1"
}
##############################################################################
# Setting Backend
##############################################################################
# terraform {
#   backend "s3" {
#   # Replace this with your bucket name!
#   bucket = "lsh-dev-ecom-test-s3-2"
#   key = "global/s3/primary/prod/terraform.tfstate"
#   region = "ap-northeast-2"
#   # Replace this with your DynamoDB table name!
#   dynamodb_table = "terraform_lock"
#   encrypt = true
#  }
# }
##############################################################################
# Create Primary Region VPC
###############################################################################
module "vpc_primary" {

  providers = {
    aws = aws.primary
  }

  source = "../../modules"

  azs = ["ap-southeast-2a", "ap-southeast-2c"]
  ecr_endpoint_sg_name = "primary-prod-ecom-sg-ecr-endpoint"
  ecr_service_name     = "com.amazonaws.ap-southeast-2.ssm"
  name                 = "primary-prod-ecom-endpoint-ecr"
  tags = {
    Name = "primary-prod-ecom-endpoint-ecr"
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
##############################################################################
# Create Secondary Region VPC
###############################################################################
module "vpc_secondary" {

  providers = {
    aws = aws.Primary
  }

  source = "../../modules"

  azs = ["ap-northeast-1a", "ap-northeast-1c"]
  ecr_endpoint_sg_name = "primary-prod-ecom-sg-ecr-endpoint"
  ecr_service_name     = "com.amazonaws.ap-northeast-1.ssm"
  name                 = "secondary-prod-ecom-endpoint-ecr"
  tags = {
    Name = "secondary-prod-ecom-endpoint-ecr"
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
# Create Primary ec2
########################################################################################
module "ec2" {
  source = "../../modules/ec2"

  ami_id                    = "ami-0c2acfcb2ac4d02a0"
  iam_instance_profile_name = "primary-dev-ec2_cli_profile_allow_ssm"
  iam_instance_profile_role = module.iam.ecom-role-ec2cli_name
  iam_role_name             = "primary-dev-ecom-role-ec2cli"
  instance_name             = "primary-dev-ecom-ec2-cli"
  instance_type             = "t3.micro"
  key_name                  = "primary-dev-ecom-kp-cli"
  pem_location              = "."
  sg_description            = "primary-dev-ecom-sg-cli"
  sg_name                   = "primary-dev-ecom-sg-cli"
  subnet_id                 = module.vpc_primary.private_subnets[0]
  user_data                 = file("${path.module}/user_data.sh")
  vpc_id                    = module.vpc_primary.vpc_id
}
#################################################################################
# Create IAM
#################################################################################
module "iam" {
  source = "../../modules/iam_with_lb"

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
  source = "../../modules/eks"

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