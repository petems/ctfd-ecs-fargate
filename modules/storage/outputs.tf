output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.ctfd_uploads[0].id : null
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.ctfd_uploads[0].arn : null
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.ctfd_uploads[0].bucket_domain_name : null
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.ctfd_uploads[0].bucket_regional_domain_name : null
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.ctfd_uploads[0].bucket : null
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = var.create_s3_bucket && var.enable_cloudfront ? aws_cloudfront_distribution.ctfd_uploads[0].id : null
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = var.create_s3_bucket && var.enable_cloudfront ? aws_cloudfront_distribution.ctfd_uploads[0].arn : null
}

output "cloudfront_distribution_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = var.create_s3_bucket && var.enable_cloudfront ? aws_cloudfront_distribution.ctfd_uploads[0].domain_name : null
}

output "ecr_repository_arn" {
  description = "ARN of the ECR repository"
  value       = var.create_ecr_repository ? aws_ecr_repository.ctfd[0].arn : null
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = var.create_ecr_repository ? aws_ecr_repository.ctfd[0].name : null
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = var.create_ecr_repository ? aws_ecr_repository.ctfd[0].repository_url : null
}

output "ecr_registry_id" {
  description = "Registry ID of the ECR repository"
  value       = var.create_ecr_repository ? aws_ecr_repository.ctfd[0].registry_id : null
}