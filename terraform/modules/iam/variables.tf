variable "s3_bucket_arn" {
  description = "ARN of the S3 bucket for IAM policy"
  type        = string
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster for IAM access entry"
  type        = string
}

variable "eks_cluster_arn" {
  description = "ARN of the EKS cluster for IAM policy"
  type        = string
}