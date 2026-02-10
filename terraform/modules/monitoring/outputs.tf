output "cloudwatch_agent_role_arn" {
  description = "ARN of the CloudWatch agent IAM role"
  value       = aws_iam_role.cloudwatch_agent.arn
}

output "cloudwatch_addon_status" {
  description = "Status of CloudWatch Observability add-on"
  value       = aws_eks_addon.cloudwatch_observability.status
}