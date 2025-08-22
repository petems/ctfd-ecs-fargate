# Random suffix for bucket name to ensure uniqueness
resource "random_string" "bucket_suffix" {
  count   = var.create_s3_bucket ? 1 : 0
  length  = 8
  special = false
  upper   = false
}

# S3 Bucket for CTFd uploads
resource "aws_s3_bucket" "ctfd_uploads" {
  count         = var.create_s3_bucket ? 1 : 0
  bucket        = var.s3_bucket_name != "" ? var.s3_bucket_name : "${var.project_name}-${var.environment}-uploads-${random_string.bucket_suffix[0].result}"
  force_destroy = var.s3_force_destroy

  tags = merge(var.tags, {
    Name    = "${var.project_name}-${var.environment}-uploads"
    Purpose = "CTFd file uploads and static assets"
  })
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "ctfd_uploads" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.ctfd_uploads[0].id
  versioning_configuration {
    status = var.s3_versioning_enabled ? "Enabled" : "Disabled"
  }
}

# S3 Bucket Server-side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "ctfd_uploads" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.ctfd_uploads[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "ctfd_uploads" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.ctfd_uploads[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket CORS Configuration
resource "aws_s3_bucket_cors_configuration" "ctfd_uploads" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.ctfd_uploads[0].id

  cors_rule {
    allowed_headers = var.cors_allowed_headers
    allowed_methods = var.cors_allowed_methods
    allowed_origins = var.cors_allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# S3 Bucket Lifecycle Configuration
resource "aws_s3_bucket_lifecycle_configuration" "ctfd_uploads" {
  count  = var.create_s3_bucket && var.s3_lifecycle_enabled ? 1 : 0
  bucket = aws_s3_bucket.ctfd_uploads[0].id

  rule {
    id     = "lifecycle_rule"
    status = "Enabled"

    filter {
      prefix = ""
    }

    # Transition to IA
    transition {
      days          = var.s3_transition_to_ia_days
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier
    transition {
      days          = var.s3_transition_to_glacier_days
      storage_class = "GLACIER"
    }

    # Expire objects
    expiration {
      days = var.s3_expiration_days
    }

    # Clean up incomplete multipart uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# S3 Bucket Policy for ECS tasks
resource "aws_s3_bucket_policy" "ctfd_uploads" {
  count  = var.create_s3_bucket ? 1 : 0
  bucket = aws_s3_bucket.ctfd_uploads[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskAccess"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.ctfd_uploads[0].arn}/*"
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/Project" = var.project_name
          }
        }
      },
      {
        Sid    = "AllowECSTaskListBucket"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.ctfd_uploads[0].arn
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/Project" = var.project_name
          }
        }
      }
    ]
  })
}

# CloudFront Distribution (optional)
resource "aws_cloudfront_distribution" "ctfd_uploads" {
  count = var.create_s3_bucket && var.enable_cloudfront ? 1 : 0

  origin {
    domain_name              = aws_s3_bucket.ctfd_uploads[0].bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.ctfd_uploads[0].id
    origin_id                = "S3-${aws_s3_bucket.ctfd_uploads[0].bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.ctfd_uploads[0].bucket}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-cdn"
  })
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "ctfd_uploads" {
  count                             = var.create_s3_bucket && var.enable_cloudfront ? 1 : 0
  name                              = "${var.project_name}-${var.environment}-oac"
  description                       = "OAC for ${var.project_name} ${var.environment}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ECR Repository for custom CTFd images
resource "aws_ecr_repository" "ctfd" {
  count                = var.create_ecr_repository ? 1 : 0
  name                 = var.ecr_repository_name != "" ? var.ecr_repository_name : "${var.project_name}-${var.environment}"
  image_tag_mutability = var.ecr_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_scan_on_push
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecr"
  })
}

# ECR Lifecycle Policy
resource "aws_ecr_lifecycle_policy" "ctfd" {
  count      = var.create_ecr_repository && var.ecr_lifecycle_policy ? 1 : 0
  repository = aws_ecr_repository.ctfd[0].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.ecr_max_image_count} images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = var.ecr_max_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than 1 day"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 1
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# ECR Repository Policy
resource "aws_ecr_repository_policy" "ctfd" {
  count      = var.create_ecr_repository ? 1 : 0
  repository = aws_ecr_repository.ctfd[0].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowECSTaskPull"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
      }
    ]
  })
}