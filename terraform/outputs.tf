output "vpc_name" {
  description = "The name of the VPC"
  value       = module.networking.pb_vpc_name
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.eks_cluster_endpoint
}

output "iam_username" {
  description = "The name of the IAM user"
  value       = module.iam.iam_username
}

output "secret_key" {
  description = "The secret access key for the IAM user"
  value       = module.iam.secret_key
  sensitive   = true
}

output "access_key_id" {
  description = "The access key ID for the IAM user"
  value       = module.iam.access_key_id
  sensitive   = true
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.storage.s3_bucket_name
}

output "lambda_function_name" {
  description = "Name of the Lambda function for asset processing"
  value       = module.storage.lambda_function_name
}

output "endpoint_mysql" {
  description = "The endpoint of the MySQL RDS instance"
  value       = module.rds.endpoint_mysql
}

output "port_mysql" {
  description = "The port of the MySQL RDS instance"
  value       = module.rds.port_mysql
}

output "endpoint_postgresql" {
  description = "The endpoint of the PostgreSQL RDS instance"
  value       = module.rds.endpoint_postgresql
}

output "port_postgresql" {
  description = "The port of the PostgreSQL RDS instance"
  value       = module.rds.port_postgresql
}