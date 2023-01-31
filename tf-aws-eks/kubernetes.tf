data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

module "eks-kubeconfig" {
  source  = "hyperbadger/eks-kubeconfig/aws"
  version = "1.0.0"

  depends_on = [module.eks]
  cluster_id = module.eks.cluster_id
}

resource "local_file" "kubeconfig" {
  content  = module.eks-kubeconfig.kubeconfig
  filename = "kubeconfig_${var.cluster_name}"
}

module "ebs-csi-driver" {
  source  = "DrFaust92/ebs-csi-driver/kubernetes"
  version = "3.5.0"

  oidc_url = module.eks.oidc_provider
}

resource "kubernetes_namespace" "waypoint_namespace" {
  metadata {
    name = "waypoint"
  }
}

resource "kubernetes_namespace" "dev_namespace" {
  metadata {
    name = "dev"
  }
}

resource "kubernetes_namespace" "pre_prod_namespace" {
  metadata {
    name = "pre-prod"
  }
}

resource "kubernetes_namespace" "prod_namespace" {
  metadata {
    name = "prod"
  }
}