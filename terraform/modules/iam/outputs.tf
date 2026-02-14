output "iam_username" {
  description = "The name of the IAM user"
  value       = aws_iam_user.iam_user.name
}

output "secret_key" {
  description = "The secret access key for the IAM user"
  value       = aws_iam_access_key.credentials.secret
}

output "access_key_id" {
  description = "The access key ID for the IAM user"
  value       = aws_iam_access_key.credentials.id
}

output "iam_user_arn" {
  description = "The ARN of the IAM user"
  value       = aws_iam_user.iam_user.arn
}

output "dev_view_console_password" {
  description = "The console password for the IAM user"
  value     = aws_iam_user_login_profile.credentials.password
  sensitive = true
}