# Basic example for CTFd ECS Fargate deployment
# This example creates all resources from scratch

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

module "ctfd" {
  source = "../../"

  # Basic configuration
  project_name = "ctfd-basic"
  environment  = "dev"
  owner        = "devops"

  # Domain configuration
  domain_name = "ctfd.example.com"

  # VPC configuration
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b"]

  # Subnet configuration
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24"]
  database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24"]

  # ECS configuration
  ecs_cpu           = 256
  ecs_memory        = 512
  ecs_desired_count = 1

  # Database configuration
  db_instance_class = "db.t3.micro"
  db_name           = "ctfd"
  db_username       = "ctfduser"

  # Monitoring configuration
  enable_monitoring            = true
  notification_email_addresses = ["admin@example.com"]
  enable_billing_alerts        = true
  billing_alert_threshold      = 50

  # Security configuration
  enable_deletion_protection = false # Allow deletion in dev
  backup_retention_period    = 1

  # Logging configuration
  log_retention_days = 7

  # Redis configuration
  enable_elasticache_redis = true
  redis_node_type          = "cache.t4.micro"
  redis_automatic_failover = true
  redis_multi_az           = false # Single AZ for dev
  redis_num_cache_nodes    = 1     # Single node for dev
}
