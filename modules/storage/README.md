# Storage Module

This module creates storage infrastructure for CTFd including S3 bucket for file uploads and ECR repository for container images.

## Features

### S3 Bucket
- **Encrypted storage** with AES256
- **Versioning** for data protection
- **Lifecycle management** with IA/Glacier transitions
- **CORS configuration** for web uploads
- **Public access blocking** for security
- **CloudFront integration** (optional)

### ECR Repository
- **Container image scanning** on push
- **Lifecycle policies** to manage image retention
- **Encryption at rest** with AES256
- **Repository policies** for ECS access

## Usage

```hcl
module "storage" {
  source = "./modules/storage"

  project_name = "ctfd"
  environment  = "dev"
  aws_region   = "us-west-2"

  # S3 Configuration
  create_s3_bucket         = true
  s3_versioning_enabled    = true
  s3_lifecycle_enabled     = true
  enable_cloudfront        = false

  # ECR Configuration
  create_ecr_repository    = true
  ecr_scan_on_push         = true
  ecr_lifecycle_policy     = true
  ecr_max_image_count      = 10

  tags = {
    Owner = "devops"
  }
}
```

## S3 Configuration for CTFd

CTFd supports S3 uploads when configured with these environment variables:
- `UPLOAD_PROVIDER=s3`
- `AWS_S3_BUCKET=bucket-name`
- `AWS_S3_REGION=region`

ECS tasks need appropriate IAM permissions to access the S3 bucket.

## ECR Usage

Push custom CTFd images to the ECR repository:

```bash
# Get login token
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-west-2.amazonaws.com

# Build and tag image
docker build -t ctfd-custom .
docker tag ctfd-custom:latest 123456789012.dkr.ecr.us-west-2.amazonaws.com/ctfd-dev:latest

# Push image
docker push 123456789012.dkr.ecr.us-west-2.amazonaws.com/ctfd-dev:latest
```

## Cost Optimization

- **Lifecycle policies** automatically transition objects to cheaper storage classes
- **ECR lifecycle policies** remove old/untagged images
- **CloudFront** reduces S3 data transfer costs (optional)

## Security Features

- **Block public access** on S3 bucket
- **Server-side encryption** for all stored objects
- **IAM-based access control** with resource-based policies
- **Container image scanning** for vulnerabilities