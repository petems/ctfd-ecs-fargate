variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner/Team responsible for the infrastructure"
  type        = string
  default     = "devops"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "ctfd"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "domain_name" {
  description = "Domain name for the CTFd application"
  type        = string

}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs :
      can(cidrnetmask(cidr))
    ])
    error_message = "All public subnet CIDR blocks must be valid CIDR notation."
  }

}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]

  validation {
    condition = alltrue([
      for cidr in var.private_subnet_cidrs :
      can(cidrnetmask(cidr))
    ])
    error_message = "All private subnet CIDR blocks must be valid CIDR notation."
  }
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  validation {
    condition = alltrue([
      for cidr in var.database_subnet_cidrs :
      can(cidrnetmask(cidr))
    ])
    error_message = "All database subnet CIDR blocks must be valid CIDR notation."
  }
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"

  validation {
    condition     = can(regex("^db\\.[a-z0-9]+\\.[a-z0-9]+$", var.db_instance_class))
    error_message = "db_instance_class must be a valid RDS instance class (e.g., db.t3.micro)."
  }
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "ctfd"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_name))
    error_message = "Database name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "ctfduser"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]*$", var.db_username))
    error_message = "Database username must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "ecs_cpu" {
  description = "CPU units for ECS task"
  type        = number
  default     = 256

  validation {
    condition     = contains([256, 512, 1024, 2048, 4096], var.ecs_cpu)
    error_message = "ECS CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "ecs_memory" {
  description = "Memory for ECS task"
  type        = number
  default     = 512

  validation {
    condition     = contains([512, 1024, 2048, 3072, 4096, 5120, 6144, 7168, 8192], var.ecs_memory)
    error_message = "ECS memory must be one of: 512, 1024, 2048, 3072, 4096, 5120, 6144, 7168, 8192."
  }
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1

  validation {
    condition     = var.ecs_desired_count >= 1 && var.ecs_desired_count <= 100
    error_message = "ECS desired count must be between 1 and 100."
  }
}

variable "ecs_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 10

  validation {
    condition     = var.ecs_max_capacity >= 1 && var.ecs_max_capacity <= 100
    error_message = "ECS max capacity must be between 1 and 100."
  }
}

variable "ecs_min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 1

  validation {
    condition     = var.ecs_min_capacity >= 1 && var.ecs_min_capacity <= 100
    error_message = "ECS min capacity must be between 1 and 100."
  }
}

variable "ctfd_container_image" {
  description = "CTFd container image"
  type        = string
  default     = "ctfd/ctfd:latest"
}

variable "ctfd_container_port" {
  description = "CTFd container port"
  type        = number
  default     = 8000

  validation {
    condition     = var.ctfd_container_port >= 1 && var.ctfd_container_port <= 65535
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for RDS"
  type        = bool
  default     = true
}

variable "backup_retention_period" {
  description = "RDS backup retention period in days"
  type        = number
  default     = 7

  validation {
    condition     = var.backup_retention_period >= 0 && var.backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "enable_monitoring" {
  description = "Enable enhanced monitoring"
  type        = bool
  default     = true
}

variable "disable_monitoring_module" {
  description = "Disable entire monitoring module (skips creation of dashboards, alarms, and related resources)"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "create_ecr_repository" {
  description = "Create ECR repository for custom CTFd images"
  type        = bool
  default     = true
}

variable "notification_email_addresses" {
  description = "List of email addresses for CloudWatch alarms"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for email in var.notification_email_addresses :
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All notification email addresses must be valid email addresses."
  }
}

variable "enable_billing_alerts" {
  description = "Enable billing alerts"
  type        = bool
  default     = false
}

variable "billing_alert_threshold" {
  description = "Billing alert threshold in USD"
  type        = number
  default     = 100

  validation {
    condition     = var.billing_alert_threshold > 0
    error_message = "Billing alert threshold must be greater than 0."
  }
}

variable "enable_backups" {
  description = "Enable automated RDS backups"
  type        = bool
  default     = true
}

variable "enable_database_alarms" {
  description = "Enable CloudWatch alarms for RDS"
  type        = bool
  default     = true
}

# BYO (Bring Your Own) Resource Support Variables
variable "existing_vpc_id" {
  description = "ID of existing VPC to use (if provided, skips VPC creation)"
  type        = string
  default     = ""

  validation {
    condition     = var.existing_vpc_id == "" || can(regex("^vpc-[a-z0-9]+$", var.existing_vpc_id))
    error_message = "Existing VPC ID must be a valid VPC ID (e.g., vpc-12345678)."
  }
}

variable "existing_public_subnet_ids" {
  description = "IDs of existing public subnets"
  type        = list(string)
  default     = []
}

variable "existing_private_subnet_ids" {
  description = "IDs of existing private subnets"
  type        = list(string)
  default     = []
}

variable "existing_database_subnet_ids" {
  description = "IDs of existing database subnets"
  type        = list(string)
  default     = []
}

variable "create_route53_zone" {
  description = "Create new Route53 hosted zone"
  type        = bool
  default     = true
}

variable "existing_route53_zone_id" {
  description = "ID of existing Route53 zone (required if create_route53_zone = false)"
  type        = string
  default     = ""

  validation {
    condition     = var.create_route53_zone || var.existing_route53_zone_id != ""
    error_message = "existing_route53_zone_id must be provided when create_route53_zone is false."
  }

  validation {
    condition     = var.existing_route53_zone_id == "" || can(regex("^Z[A-Z0-9]+$", var.existing_route53_zone_id))
    error_message = "Existing Route53 zone ID must be a valid zone ID (e.g., Z1234567890ABC)."
  }
}

# ElastiCache Redis Configuration
variable "enable_elasticache_redis" {
  description = "Enable ElastiCache Redis cluster"
  type        = bool
  default     = true
}

variable "redis_node_type" {
  description = "ElastiCache Redis node type"
  type        = string
  default     = "cache.t4.micro"

  validation {
    condition     = can(regex("^cache\\.[a-z0-9]+\\.[a-z0-9]+$", var.redis_node_type))
    error_message = "Redis node type must be a valid ElastiCache node type (e.g., cache.t4.micro)."
  }
}

variable "redis_automatic_failover" {
  description = "Enable automatic failover for Redis cluster"
  type        = bool
  default     = true
}

variable "redis_multi_az" {
  description = "Enable Multi-AZ for Redis cluster"
  type        = bool
  default     = true
}

variable "redis_num_cache_nodes" {
  description = "Number of cache nodes in Redis cluster"
  type        = number
  default     = 2

  validation {
    condition     = var.redis_num_cache_nodes >= 1 && var.redis_num_cache_nodes <= 20
    error_message = "Redis number of cache nodes must be between 1 and 20."
  }
}

variable "redis_auth_token" {
  description = "Auth token for Redis cluster (optional)"
  type        = string
  default     = ""
  sensitive   = true

  validation {
    condition     = var.redis_auth_token == "" || length(var.redis_auth_token) >= 16
    error_message = "Redis auth token must be at least 16 characters long if provided."
  }
}