######################################################################################################################
# Kubernetes - EKS Cluster Data Source
######################################################################################################################
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
  depends_on = [ var.dependency ]
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
  depends_on = [ var.dependency ]
}

######################################################################################################################
# Kubernetes Provider
######################################################################################################################
provider "kubernetes" {
  alias                  = "eks"
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

######################################################################################################################
# Helm Provider
######################################################################################################################
provider "helm" {
  alias = "eks-helm"

  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

######################################################################################################################
# Helm Release for AWS Load Balancer Controller
######################################################################################################################
resource "helm_release" "aws_load_balancer_controller" {
  provider   = helm.eks-helm
  name       = "${var.environment}-aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  version    = "1.6.2"
  repository = "https://aws.github.io/eks-charts"
  namespace  = "kube-system"

  dynamic "set" {
    for_each = {
      "clusterName"                                               = var.cluster_name
      "serviceAccount.create"                                     = "true"
      "serviceAccount.name"                                       = var.lb_controller_service_account_name
      "region"                                                    = var.region
      "vpcId"                                                     = var.vpc_id
      "image.repository"                                          = var.alb_image_repository
      "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" = var.lb_controller_role_arn
    }

    content {
      name  = set.key
      value = set.value
    }
  }

  depends_on = [ var.dependency ]

}
