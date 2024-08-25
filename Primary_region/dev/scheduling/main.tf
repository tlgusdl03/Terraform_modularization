provider "aws" {
  alias = "primary"
  region = "ap-southeast-2"
}

provider "aws" {
  alias = "secondary"
  region = "ap-southeast-1"
}
##############################################################################
# Setting Backend
##############################################################################
terraform {
  backend "s3" {
  # Replace this with your bucket name!
  bucket = "lsh-dev-ecom-test-s3-2"
  key = "global/s3/primary/dev/terraform.tfstate"
  region = "ap-southeast-2"
  # Replace this with your DynamoDB table name!
  dynamodb_table = "lsh-dev-ecom-dynamodbTable-terraform-lock"
  encrypt = true
 }
}
##############################################################################
# Create VPC
###############################################################################
# module "vpc" {
#
#   providers = {
#     aws = aws.primary
#   }
#
#   source = "../../../modules/vpc"
#
#   azs = ["ap-southeast-2a", "ap-southeast-2c"]
#   ecr_endpoint_sg_name = "primary-dev-ecom-sg-ecrendpoint-ecr"
#   ecr_service_name     = "com.amazonaws.ap-southeast-2.ssm"
#   name                 = "primary-dev-ecom-endpoint-ecr"
#   tags = {
#     Name = "primary-dev-ecom-vpc"
#   }
#   vpc_cidr             = "10.0.0.0/24"
#
#   # public_subnets: CIDR 블록 /27 크기 (32 IP)
#   database_subnets_cidr = [
#     "10.0.0.192/27",  # db-pri01: 10.0.0.192/27
#     "10.0.0.224/27"  # db-pri02: 10.0.0.224/27
#   ]
#   # private_subnets: CIDR 블록 /26 크기 (64 IP)
#   private_subnets_cidr = [
#     "10.0.0.64/26",  # pri01: 10.0.0.64/26
#     "10.0.0.128/26"  # pri02: 10.0.0.128/64
#   ]
#   # db_subnets: CIDR 블록 /27 크기 (32 IP)
#   public_subnets_cidr = [
#     "10.0.0.0/27",  # pub01: 10.0.0.0/27
#     "10.0.0.32/27" # pub02: 10.0.0.32/27
#   ]
#
#   ecr_endpoint_subnet_ids = module.vpc.private_subnets
#
# }
#########################################################################################
# Create ec2
########################################################################################
# 기본 VPC를 가져오는 데이터 소스
data "aws_vpc" "default"{
  default = true
}

# 기본 VPC에 속한 기본 서브넷을 가져오는 데이터 소스
data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "ec2" {

  providers = {
    aws = aws.primary
  }

  source = "../../../modules/ec2_schedule"

  ami_id                    = "ami-01fb4de0e9f8f22a7"
  iam_instance_profile_name = "primary-dev-ec2_scheduling_profile_allow_ssm"
  iam_instance_profile_role = module.iam_without_lb.ecom-role-ec2cli_name
  iam_role_name             = "primary-dev-ecom-role-ec2-schedule"
  instance_name             = "primary-dev-ecom-ec2-schedule"
  instance_type             = "m5.large"
  key_name                  = "primary-dev-ecom-kp-schedule"
  pem_location              = "."
  sg_description            = "primary-dev-ecom-sg-schedule"
  sg_name                   = "primary-dev-ecom-sg-schedule"
  subnet_id                 = data.aws_subnets.default.ids[0]
  user_data                 = file("${path.module}/user_data.sh")
  vpc_id                    = data.aws_vpc.default.id
}
#################################################################################
# Create IAM
#################################################################################
module "iam_without_lb" {

  providers = {
    aws = aws.primary
  }

  source = "../../../modules/iam_without_lb"

  ec2cli_managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
  ]
  ec2cli_role_name                 = "primary-dev-ecom-role-ec2-schedule"

}