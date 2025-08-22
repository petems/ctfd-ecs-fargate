variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "create_s3_bucket" {
  description = "Create S3 bucket for file uploads"
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket (if not provided, will be auto-generated)"
  type        = string
  default     = ""
}

variable "s3_force_destroy" {
  description = "Force destroy S3 bucket even if not empty"
  type        = bool
  default     = false
}

variable "create_ecr_repository" {
  description = "Create ECR repository for custom CTFd images"
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = ""
}

variable "ecr_image_tag_mutability" {
  description = "Image tag mutability for ECR repository"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "ecr_lifecycle_policy" {
  description = "Enable ECR lifecycle policy to manage image retention"
  type        = bool
  default     = true
}

variable "ecr_max_image_count" {
  description = "Maximum number of images to retain in ECR"
  type        = number
  default     = 10
}

variable "s3_versioning_enabled" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "s3_lifecycle_enabled" {
  description = "Enable S3 lifecycle management"
  type        = bool
  default     = true
}

variable "s3_transition_to_ia_days" {
  description = "Days after which to transition objects to IA"
  type        = number
  default     = 30
}

variable "s3_transition_to_glacier_days" {
  description = "Days after which to transition objects to Glacier"
  type        = number
  default     = 90
}

variable "s3_expiration_days" {
  description = "Days after which to expire objects"
  type        = number
  default     = 365
}

variable "enable_cloudfront" {
  description = "Create CloudFront distribution for S3 static assets"
  type        = bool
  default     = false
}

variable "cloudfront_price_class" {
  description = "CloudFront price class"
  type        = string
  default     = "PriceClass_100"
}

variable "cors_allowed_origins" {
  description = "CORS allowed origins for S3 bucket"
  type        = list(string)
  default     = []

  validation {
    condition     = var.environment != "prod" || !contains(var.cors_allowed_origins, "*")
    error_message = "Wildcard CORS origins are not allowed in production environments."
  }
}

variable "cors_allowed_methods" {
  description = "CORS allowed methods for S3 bucket"
  type        = list(string)
  default     = ["GET", "PUT", "POST", "DELETE", "HEAD"]
}

variable "cors_allowed_headers" {
  description = "CORS allowed headers for S3 bucket"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}