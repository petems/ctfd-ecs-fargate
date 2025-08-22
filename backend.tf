terraform {
  backend "s3" {
    bucket         = "ctfd-terraform-state-${var.aws_region}"
    key            = "ctfd-ecs-fargate/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "ctfd-terraform-state-lock"
    encrypt        = true

    # Optional: Enable versioning on the S3 bucket
    versioning = true

    # Optional: Server-side encryption
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
      }
    }
  }

  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ctfd-infrastructure"
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
    }
  }
}