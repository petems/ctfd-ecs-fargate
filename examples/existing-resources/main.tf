# Existing Resources example for CTFd ECS Fargate deployment
# This example uses existing VPC, subnets, and Route53 zone

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Data sources for existing resources
data "aws_vpc" "existing" {
  tags = {
    Name = "existing-vpc"
  }
}

data "aws_subnets" "existing_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  tags = {
    Type = "Public"
  }
}

data "aws_subnets" "existing_private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  tags = {
    Type = "Private"
  }
}

data "aws_subnets" "existing_database" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing.id]
  }

  tags = {
    Type = "Database"
  }
}

data "aws_route53_zone" "existing" {
  name = "example.com"
}

module "ctfd" {
  source = "../../"

  # Basic configuration
  project_name = "ctfd-existing"
  environment  = "prod"
  owner        = "devops"

  # Domain configuration
  domain_name              = "ctfd.example.com"
  create_route53_zone      = false
  existing_route53_zone_id = data.aws_route53_zone.existing.zone_id

  # Existing VPC and subnets
  existing_vpc_id              = data.aws_vpc.existing.id
  existing_public_subnet_ids   = data.aws_subnets.existing_public.ids
  existing_private_subnet_ids  = data.aws_subnets.existing_private.ids
  existing_database_subnet_ids = data.aws_subnets.existing_database.ids

  # VPC configuration (ignored when using existing VPC)
  vpc_cidr              = "10.0.0.0/16"
  availability_zones    = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  # ECS configuration
  ecs_cpu           = 1024
  ecs_memory        = 2048
  ecs_desired_count = 2
  ecs_max_capacity  = 10
  ecs_min_capacity  = 2

  # Database configuration
  db_instance_class = "db.t3.small"
  db_name           = "ctfd"
  db_username       = "ctfduser"

  # Monitoring configuration
  enable_monitoring            = true
  notification_email_addresses = ["admin@example.com", "devops@example.com"]
  enable_billing_alerts        = true
  billing_alert_threshold      = 200

  # Security configuration
  enable_deletion_protection = true
  backup_retention_period    = 30

  # Logging configuration
  log_retention_days = 30
}
