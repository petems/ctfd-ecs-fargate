variable "project_name" {
  description = "Name of the project"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "vpc_id" {
  description = "VPC ID where ElastiCache will be deployed"
  type        = string

  validation {
    condition     = can(regex("^vpc-[a-z0-9]+$", var.vpc_id))
    error_message = "VPC ID must be a valid VPC ID (e.g., vpc-12345678)."
  }
}

variable "database_subnet_ids" {
  description = "Database subnet IDs for ElastiCache subnet group"
  type        = list(string)

  validation {
    condition = alltrue([
      for subnet_id in var.database_subnet_ids :
      can(regex("^subnet-[a-z0-9]+$", subnet_id))
    ])
    error_message = "All database subnet IDs must be valid subnet IDs (e.g., subnet-12345678)."
  }
}

variable "ecs_security_group_ids" {
  description = "ECS security group IDs that need access to Redis"
  type        = list(string)

  validation {
    condition = alltrue([
      for sg_id in var.ecs_security_group_ids :
      can(regex("^sg-[a-z0-9]+$", sg_id))
    ])
    error_message = "All ECS security group IDs must be valid security group IDs (e.g., sg-12345678)."
  }
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

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention days must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653."
  }
}

variable "alarm_actions" {
  description = "List of ARNs for CloudWatch alarm actions (SNS topics, etc.)"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
