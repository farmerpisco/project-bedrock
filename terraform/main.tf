terraform {
  required_version = ">= 1.8.0"

  backend "s3" {
    bucket       = "project-bedrock-state-bucket-1570"
    key          = "project-bedrock/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "barakat-2025-capstone"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.eks_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]
    command     = "aws"
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.eks_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.eks_cluster_name]
      command     = "aws"
    }
  }
}

module "networking" {
  source = "./modules/networking"

  project_name = var.project_name
  cidr_block   = var.cidr_block

}

module "eks" {
  source = "./modules/eks"

  project_name         = var.project_name
  pb_eks_cluster_sg_id = module.networking.pb_eks_cluster_sg_id
  public_subnet_ids    = module.networking.pb_public_subnet_ids
  private_subnet_ids   = module.networking.pb_private_subnet_ids
  instance_type        = var.instance_type
  iam_user_arn         = module.iam.iam_user_arn

}

module "ingress" {
  source = "./modules/ingress"

  aws_region              = var.aws_region
  project_name            = var.project_name
  pb_vpc_id               = module.networking.pb_vpc_id
  pb_eks_cluster_name     = module.eks.eks_cluster_name
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  oidc_provider_arn       = module.eks.oidc_provider_arn

  depends_on = [module.eks]
}

module "monitoring" {
  source = "./modules/monitoring"

  project_name      = var.project_name
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.cluster_oidc_issuer_url

  depends_on = [module.eks]
}

module "iam" {
  source = "./modules/iam"

  s3_bucket_arn    = module.storage.s3_bucket_arn
  eks_cluster_name = module.eks.eks_cluster_name
  eks_cluster_arn  = module.eks.eks_cluster_arn
}

module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
}

module "secret-manager" {
  source = "./modules/secret-manager"

  project_name = var.project_name
  db_username  = var.db_username
  db_password  = var.db_password
}

module "rds" {
  source = "./modules/rds"

  project_name = var.project_name
  db_username  = var.db_username
  db_password  = var.db_password

  pb_rds_sg_id             = module.networking.pb_rds_sg_id
  pb_rds_subnet_group_name = module.networking.pb_rds_subnet_group_name

  depends_on = [module.networking, module.secret-manager]

}

#