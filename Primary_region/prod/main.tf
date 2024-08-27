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
  bucket = "lsh-dev-ecom-test-s3-2"
  key = "global/s3/primary/prod/terraform.tfstate"
  region = "ap-southeast-2"
  # Replace this with your DynamoDB table name!
  dynamodb_table = "lsh-prod-ecom-dynamodbTable-terraform-lock"
  encrypt = true
 }
}
##############################################################################
# Create Primary Region VPC
###############################################################################
module "vpc_primary" {

  providers = {
    aws = aws.primary
  }

  source = "../../modules/vpc"

  azs = ["ap-northeast-2a", "ap-northeast-2c"]
  ecr_endpoint_sg_name = "primary-prod-ecom-sg-ecr-endpoint"
  ecr_service_name     = "com.amazonaws.ap-northeast-2.ssm"
  name                 = "primary-prod-ecom-endpoint-ecr"
  tags = {
    Name = "primary-prod-ecom-vpc"
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

  ecr_endpoint_subnet_ids = module.vpc_primary.private_subnets
}
##############################################################################
# Create Secondary Region VPC
###############################################################################
module "vpc_secondary" {

  providers = {
    aws = aws.secondary
  }

  source = "../../modules/vpc"

  azs = ["us-east-1a", "us-east-1c"]
  ecr_endpoint_sg_name = "secondary-prod-ecom-sg-ecr-endpoint"
  ecr_service_name     = "com.amazonaws.us-east-1.ssm"
  name                 = "secondary-prod-ecom-endpoint-ecr"
  tags = {
    Name = "secondary-prod-ecom-vpc"
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

  ecr_endpoint_subnet_ids = module.vpc_secondary.private_subnets
}
#########################################################################################
# Create Primary ec2
########################################################################################
module "ec2" {
  providers = {
    aws = aws.primary
  }
  source = "../../modules/ec2"

  ami_id                    = "ami-008d41dbe16db6778"
  iam_instance_profile_name = "primary-prod-ec2_cli_profile_allow_ssm"
  iam_instance_profile_role = module.iam.ecom-role-ec2cli_name
  iam_role_name             = "primary-prod-ec2_cli_profile_allow_ssm"
  instance_name             = "primary-prod-ecom-ec2-cli"
  instance_type             = "t3.micro"
  key_name                  = "primary-prod-ecom-kp-cli"
  pem_location              = "."
  sg_description            = "primary-prod-ecom-sg-cli"
  sg_name                   = "primary-prod-ecom-sg-cli"
  subnet_id                 = module.vpc_primary.private_subnets[0]
  user_data                 = file("${path.module}/user_data.sh")
  vpc_id                    = module.vpc_primary.vpc_id
}
#################################################################################
# Create IAM
#################################################################################
module "iam" {
  source = "../../modules/iam_with_lb"

  ec2cli_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  ]
  ec2cli_role_name                 = "primary-prod-ec2_cli_profile_allow_ssm"
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

  source = "../../modules/eks"
  additional_security_group_id = module.ec2.ec2-sg-cli
  cluster_name                 = "primary-dev-ecom-cluster-3"
  cluster_version              = "1.30"
  private_subnets = module.vpc_primary.private_subnets
  vpc_id                       = module.vpc_primary.vpc_id

  eks_node_group_node_desire_size = 2
  eks_node_group_node_max_size    = 4
  eks_node_group_node_min_size    = 2

  lb_controller_iam_role_name = "primary-prod-ecom-lb-controller-iam-role"

}
#####################################################################################
# Create Kubernetes Helm
#####################################################################################
module "kubernetes" {
  providers = {
    aws = aws.primary
  }

  source = "../../modules/kubernetes"

  alb_image_repository               = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"
  cluster_name                       = module.eks.eks_cluster_name
  dependency                         = module.eks
  lb_controller_role_arn             = module.eks.lb_controller_role_arn
  lb_controller_service_account_name = "aws-load-balancer-controller"
  region                             = "ap-northeast-2"
  vpc_id                             = module.vpc_primary.vpc_id

  environment = "prod"
}
#######################################################################################
# Create Single redis
#######################################################################################
module "single_redis" {

  providers = {
    aws = aws.primary
  }

  source = "../../modules/single_redis"

  node_security_group_ids = [module.eks.node_security_group_id]
  preferred_cache_cluster_azs = module.vpc_primary.azs
  replication_group_id   = "primary-prod-ecom-redis"
  security_group_name    = "primary-prod-ecom-sg-redis"
  subnet_group_name      = "primary-prod-ecom-subgroup-redis"
  subnet_ids = module.vpc_primary.database_subnets
  vpc_id                 = module.vpc_primary.vpc_id
  depends_on = [module.vpc_primary]

  redis_number_cache_cluster = 2
}
########################################################################################
# Create Aurora Global Cluster
########################################################################################
module "global_aurora" {
  source = "../../modules/rds/rds_global_cluster"

  database_name                             = "devecomauroracluster"
  engine                                    = "aurora-mysql"
  engine_version                            = ""
  global_cluster_identifier                 = "dev-ecom-global-database"
  primary_vpc_database_subnet_group_name    = "primary-prod-ecom-subgroup-rds"
  primary_vpc_id                            = module.vpc_primary.vpc_id
  # 해당 리전 aurora 클러스터에 적용할 보안그룹에서 허용할 cidr
  primary_vpc_private_subnets_cidr_blocks   = [
    "10.0.0.64/26",  # pri01: 10.0.0.64/26
    "10.0.0.128/26"  # pri02: 10.0.0.128/64
  ]
  secondary_vpc_database_subnet_group_name  = "secondary-prod-ecom-subgroup-rds"
  secondary_vpc_id                          = module.vpc_secondary.vpc_id
  # 해당 리전 aurora 클러스터에 적용할 보안그룹에서 허용할 cidr
  secondary_vpc_private_subnets_cidr_blocks = [
    "10.0.0.64/26",  # pri01: 10.0.0.64/26
    "10.0.0.128/26"  # pri02: 10.0.0.128/64
  ]

  node_security_group_ids = [module.eks.node_security_group_id]

  primary_azs   = module.vpc_primary.azs
  secondary_azs = module.vpc_secondary.azs
}