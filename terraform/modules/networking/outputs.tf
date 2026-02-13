output "pb_vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.pb_vpc.id
}

output "pb_vpc_name" {
  description = "The name of the VPC"
  value       = aws_vpc.pb_vpc.tags["Name"]
}

output "pb_eks_cluster_sg_id" {
  description = "The ID of the EKS cluster security group"
  value       = aws_security_group.pb_eks_cluster_sg.id
}

output "pb_private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.pb_private_subnet[*].id
}

output "pb_public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.pb_public_subnet[*].id
}

output "pb_rds_sg_id" {
  description = "The ID of the RDS security group"
  value       = aws_security_group.pb_rds_sg.id
}

output "pb_rds_subnet_group_name" {
  description = "The name of the RDS subnet group"
  value       = aws_db_subnet_group.pb_rds_subnet_group.name
}