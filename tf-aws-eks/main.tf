terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_availability_zones" "available" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name                 = "k8s-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.30.3"

  cluster_name    = var.cluster_name
  cluster_version = "1.24"
  subnet_ids      = module.vpc.private_subnets

  vpc_id = module.vpc.vpc_id

  eks_managed_node_groups = {
    first = {
      desired_capacity = 1
      max_capacity     = 5
      min_capacity     = 1

      instance_type = "m5.large"
    }
  }
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

resource "aws_ecr_repository" "waypoint_container_repository" {
  name                 = "waypoint-registry"
  image_tag_mutability = "MUTABLE"
}