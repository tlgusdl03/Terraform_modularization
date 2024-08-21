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
  region = "ap-northeast-2"
}

provider "aws" {
  alias = "secondary"
  region = "us-east-1"
}
##############################################################################
# Setting Backend
##############################################################################
terraform {
  backend "s3" {
  # Replace this with your bucket name!
  bucket = "lsh-terraform-backend-test"
  key = "global/s3/terraform.tfstate"
  region = "ap-northeast-2"
  # Replace this with your DynamoDB table name!
  dynamodb_table = "terraform_lock"
  encrypt = true
 }
}
##############################################################################
# Create VPC
###############################################################################
module "vpc" {

  providers = {
    aws = aws.primary
  }

  source = "../modules/vpc"

  azs = ["ap-northeast-2a", "ap-northeast-2c"]
  ecr_endpoint_sg_name = "dev-ecom-sg-ecrendpoint-ecr"
  ecr_service_name     = "com.amazonaws.ap-northeast-2.ssm"
  name                 = "dev-ecom-endpoint-ecr"
  tags = {
    Name = "dev-ecom-vpc"
  }
  vpc_cidr             = "10.0.0.0/24"

  # public_subnets: CIDR 블록 /27 크기 (32 IP)
  database_subnets_cidr = [
    "10.0.0.192/27",  # db-pri01: 10.0.0.192/27
    "10.0.0.224/27"  # db-pri02: 10.0.0.224/27
  ]
  # private_subnets: CIDR 블록 /26 크기 (64 IP)
  private_subnets_cidr = [
    "10.0.0.64/26",  # pri01: 10.0.0.64/26
    "10.0.0.128/26"  # pri02: 10.0.0.128/64
  ]
  # db_subnets: CIDR 블록 /27 크기 (32 IP)
  public_subnets_cidr = [
    "10.0.0.0/27",  # pub01: 10.0.0.0/27
    "10.0.0.32/27" # pub02: 10.0.0.32/27
  ]

  ecr_endpoint_subnet_ids = module.vpc.private_subnets
}
#########################################################################################
# Create ec2
########################################################################################
module "ec2" {

  providers = {
    aws = aws.primary
  }

  source = "../modules/ec2"

  ami_id                    = "ami-0c2acfcb2ac4d02a0"
  iam_instance_profile_name = "ec2_cli_profile_allow_ssm"
  iam_instance_profile_role = module.iam.ecom-role-ec2cli_name
  iam_role_name             = "dev-ecom-role-ec2cli"
  instance_name             = "dev-ecom-ec2-cli"
  instance_type             = "t3.micro"
  key_name                  = "dev-ecom-kp-cli"
  pem_location              = "."
  sg_description            = "dev-ecom-sg-cli"
  sg_name                   = "dev-ecom-sg-cli"
  subnet_id                 = module.vpc.private_subnets[0]
  user_data                 = file("${path.module}/user_data.sh")
  vpc_id                    = module.vpc.vpc_id
}
#################################################################################
# Create IAM
#################################################################################
module "iam" {

  providers = {
    aws = aws.primary
  }

  source = "../modules/iam"

  ec2cli_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"]
  ec2cli_role_name                 = "dev-ecom-role-ec2cli"
  lb_controller_policy_name_prefix = "AWSLoadBalancerControllerIAMPolicy"
  lb_controller_policy_url         = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.2/docs/install/iam_policy.json"
  lb_controller_role_name          = module.eks.lb_controller_role_name
}
#####################################################################################
# Create EKS
#####################################################################################
module "eks" {

  providers = {
    aws = aws.primary
  }

  source = "../modules/eks"
  additional_security_group_id = module.ec2.ec2-sg-cli
  cluster_name                 = "dev-ecom-cluster"
  cluster_version              = "1.30"
  private_subnets = module.vpc.private_subnets
  vpc_id                       = module.vpc.vpc_id

  eks_node_group_node_desire_size = 1
  eks_node_group_node_max_size    = 1
  eks_node_group_node_min_size    = 1

  lb_controller_iam_role_name = "dev-ecom-lb-controller-iam-role"
}
####################################################################################
# Create Kubernetes Helm
####################################################################################
module "kubernetes" {
  source = "../modules/kubernetes"

  alb_image_repository               = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"
  cluster_name                       = module.eks.eks_cluster_name
  dependency                         = module.eks
  lb_controller_role_arn             = module.eks.lb_controller_role_arn
  lb_controller_service_account_name = "aws-load-balancer-controller"
  region                             = "ap-northeast-2"
  vpc_id                             = module.vpc.vpc_id

  environment = "dev"

}
#######################################################################################
# Create Single redis
#######################################################################################
module "single_redis" {
  source = "../modules/single_redis"

  node_security_group_ids = [module.eks.node_security_group_id]
  preferred_cache_cluster_azs = module.vpc.azs
  replication_group_id   = "primary-dev-ecom-redis"
  security_group_name    = "primary-dev-ecom-sg-redis"
  subnet_group_name      = "primary-dev-ecom-subgroup-redis"
  subnet_ids = module.vpc.database_subnets
  vpc_id                 = module.vpc.vpc_id
  depends_on = [module.vpc]
}