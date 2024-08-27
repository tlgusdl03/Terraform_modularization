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
  key = "global/s3/secondary/prod/terraform.tfstate"
  region = "ap-southeast-2"
  # Replace this with your DynamoDB table name!
  dynamodb_table = "lsh-prod-secondary-ecom-dynamodbTable-terraform-lock"
  encrypt = true
 }
}
##############################################################################
# Import Data
##############################################################################
data "aws_vpc" "secondary_vpc" {
  provider = aws.secondary
  filter {
    name   = "vpc-id"
    values = ["vpc-0265d1efbf6e50dcc"]  # 원하는 VPC의 id로 변경
  }
}

data "aws_subnets" "secondary_vpc_subnet" {
  provider = aws.secondary
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.secondary_vpc.id]  # 사용할 VPC의 ID
  }
}

data "aws_subnets" "public_subnets" {
  provider = aws.secondary
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.secondary_vpc.id]  # 사용할 VPC의 ID
  }

  filter {
    name   = "tag:Name"
    values = ["secondary-prod-ecom-endpoint-ecr-public-subnet"]  # "type" 태그가 "public"인 서브넷만 필터링
  }
}

data "aws_subnets" "private_subnets" {
  provider = aws.secondary
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.secondary_vpc.id]  # 사용할 VPC의 ID
  }

  filter {
    name   = "tag:Name"
    values = ["secondary-prod-ecom-endpoint-ecr-private-subnet"]  # "type" 태그가 "private"인 서브넷만 필터링
  }
}

data "aws_subnets" "database_subnet" {
  provider = aws.secondary
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.secondary_vpc.id]  # 사용할 VPC의 ID
  }

  filter {
    name   = "tag:Name"
    values = ["secondary-prod-ecom-endpoint-ecr-db-subnet"]  # "type" 태그가 "database"인 서브넷만 필터링
  }
}

#########################################################################################
# Create Secondary ec2
########################################################################################
module "ec2" {
  source = "../../modules/ec2"

  providers = {
    aws = aws.secondary
  }

  ami_id                    = "ami-066784287e358dad1"
  iam_instance_profile_name = "secondary-prod-ec2_cli_profile_allow_ssm"
  iam_instance_profile_role = module.iam.ecom-role-ec2cli_name
  iam_role_name             = "secondary-prod-ec2_cli_profile_allow_ssm"
  instance_name             = "secondary-prod-ecom-ec2-cli"
  instance_type             = "t3.micro"
  key_name                  = "secondary-prod-ecom-kp-cli"
  pem_location              = "."
  sg_description            = "secondary-prod-ecom-sg-cli"
  sg_name                   = "secondary-prod-ecom-sg-cli"
  subnet_id                 = data.aws_subnets.public_subnets.ids[0]
  user_data                 = file("${path.module}/user_data.sh")
  vpc_id                    = data.aws_vpc.secondary_vpc.id
}
#################################################################################
# Create IAM
#################################################################################
module "iam" {
  source = "../../modules/iam_with_lb"

  ec2cli_managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"]
  ec2cli_role_name                 = "secondary-prod-ec2_cli_profile_allow_ssm"
  lb_controller_policy_name_prefix = "AWSLoadBalancerControllerIAMPolicy"
  lb_controller_policy_url         = "https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.2/docs/install/iam_policy.json"
  lb_controller_role_name          = module.eks.lb_controller_role_name
}
#####################################################################################
# Create EKS
#####################################################################################
module "eks" {

  providers = {
    aws = aws.secondary
  }

  source = "../../modules/eks"

  additional_security_group_id = module.ec2.ec2-sg-cli
  cluster_name                 = "cluster"
  cluster_version              = "1.30"
  private_subnets = data.aws_subnets.private_subnets.ids
  vpc_id                       = data.aws_vpc.secondary_vpc.id

  eks_node_group_node_desire_size = 2
  eks_node_group_node_max_size    = 4
  eks_node_group_node_min_size    = 2
  lb_controller_iam_role_name     = "secondary-prod-ecom-lb-controller-role"
}
####################################################################################
# Create Kubernetes Helm
####################################################################################
module "kubernetes" {
  providers = {
    aws = aws.secondary
  }
  source = "../../modules/kubernetes"

  alb_image_repository               = "602401143452.dkr.ecr.ap-northeast-2.amazonaws.com/amazon/aws-load-balancer-controller"
  cluster_name                       = module.eks.eks_cluster_name
  dependency                         = module.eks
  lb_controller_role_arn             = module.eks.lb_controller_role_arn
  lb_controller_service_account_name = "aws-load-balancer-controller"
  region                             = "us-east-1"
  vpc_id                             = data.aws_vpc.secondary_vpc.id

  environment = "prod"
}
#######################################################################################
# Create Single redis
#######################################################################################
module "single_redis" {

  providers = {
    aws = aws.secondary
  }

  source = "../../modules/single_redis"

  node_security_group_ids = [module.eks.node_security_group_id]
  preferred_cache_cluster_azs = ["us-east-1a", "us-east-1c"]
  replication_group_id   = "secondary-prod-ecom-redis"
  security_group_name    = "secondary-prod-ecom-sg-redis"
  subnet_group_name      = "secondary-prod-ecom-subgroup-redis"
  subnet_ids = data.aws_subnets.database_subnet.ids
  vpc_id                 = data.aws_vpc.secondary_vpc.id
  depends_on = [data.aws_vpc.secondary_vpc]

  redis_number_cache_cluster = 2
}