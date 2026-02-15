variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
}

variable "project_name" {
  description = "Name of the project for all resources"
  type        = string
}

variable "pb_vpc_id" {
  description = "VPC ID for EKS cluster"
  type        = string
}

variable "pb_eks_cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster (used for IRSA)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster (used for IRSA)"
  type        = string
}