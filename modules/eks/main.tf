################################################################################
## Create EKS Cluster
################################################################################
# EKS 클러스터를 생성함
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      cluster_name = var.cluster_name
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.private_subnets
  #
  cluster_additional_security_group_ids = [var.additional_security_group_id]

  eks_managed_node_group_defaults = {
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    node = {
      min_size     = var.eks_node_group_node_min_size
      max_size     = var.eks_node_group_node_max_size
      desired_size = var.eks_node_group_node_desire_size
      instance_types = ["t3.medium"]
    }
  }
}

################################################################################
## VPC CNI IRSA 설정
################################################################################
module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 4.12"

  role_name_prefix      = "VPC-CNI-IRSA"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

################################################################################
## 로드밸런서 콘트롤러 설정
################################################################################
locals {
  lb_controller_iam_role_name = "lb-controller-role"
  k8s_aws_lb_service_account_namespace = "kube-system"
  lb_controller_service_account_name   = "aws-load-balancer-controller"
}

# EKS 클러스터 인증 데이터 소스
data "aws_eks_cluster_auth" "eks" {
  name = var.cluster_name
}

# Load Balancer Controller ROLE 설정
module "lb_controller_role" {
  source      = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version     = "v5.1.0"
  create_role = true

  role_name        = var.lb_controller_iam_role_name
  role_path        = "/"
  role_description = "Used by AWS Load Balancer Controller for EKS"
  provider_url     = replace(module.eks.cluster_oidc_issuer_url, "https://", "")

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:${local.k8s_aws_lb_service_account_namespace}:${local.lb_controller_service_account_name}"
  ]
  oidc_fully_qualified_audiences = [
    "sts.amazonaws.com"
  ]
}

# ################################################################################
# # AWS Load Balancer Controller IAM Role Policy
# ################################################################################
# data "http" "iam_policy" {
#   url = var.lb_controller_policy_url
# }
#
# resource "aws_iam_role_policy" "eks_controller_policy" {
#   name_prefix = var.lb_controller_policy_name_prefix
#   role        = var.lb_controller_role_name
#   policy      = data.http.iam_policy.response_body
# }