output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.pb_s3.bucket
}

output "lambda_function_name" {
  description = "Name of the Lambda function for asset processing"
  value       = aws_lambda_function.bedrock_asset_processor.function_name
}
