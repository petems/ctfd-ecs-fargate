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

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for ECS service"
  type        = list(string)
}

variable "ecs_security_group_ids" {
  description = "List of security group IDs for ECS tasks"
  type        = list(string)
}

variable "alb_target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

# Container Configuration
variable "container_image" {
  description = "Docker image for the CTFd container"
  type        = string
  default     = "ctfd/ctfd:latest"
}

variable "container_port" {
  description = "Port exposed by the CTFd container"
  type        = number
  default     = 8000
}

variable "container_cpu" {
  description = "CPU units for the container (1024 = 1 vCPU)"
  type        = number
  default     = 256
}

variable "container_memory" {
  description = "Memory for the container in MB"
  type        = number
  default     = 512
}

variable "container_memory_reservation" {
  description = "Soft limit of memory for the container in MB"
  type        = number
  default     = 256
}

# Service Configuration
variable "desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum number of ECS tasks for auto scaling"
  type        = number
  default     = 10
}

variable "min_capacity" {
  description = "Minimum number of ECS tasks for auto scaling"
  type        = number
  default     = 1
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period for ECS service"
  type        = number
  default     = 300
}

variable "deployment_maximum_percent" {
  description = "Maximum percentage of tasks that can run during deployment"
  type        = number
  default     = 200
}

variable "deployment_minimum_healthy_percent" {
  description = "Minimum percentage of healthy tasks during deployment"
  type        = number
  default     = 50
}

variable "enable_execute_command" {
  description = "Enable ECS Exec for debugging"
  type        = bool
  default     = false
}

# Auto Scaling Configuration
variable "enable_auto_scaling" {
  description = "Enable auto scaling for ECS service"
  type        = bool
  default     = true
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80
}

variable "scale_up_cooldown" {
  description = "Cooldown period for scale up in seconds"
  type        = number
  default     = 300
}

variable "scale_down_cooldown" {
  description = "Cooldown period for scale down in seconds"
  type        = number
  default     = 300
}

# Database Configuration
variable "database_secret_arn" {
  description = "ARN of the Secrets Manager secret containing database credentials"
  type        = string
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "ctfd"
}

# Storage Configuration
variable "s3_bucket_name" {
  description = "Name of the S3 bucket for uploads"
  type        = string
  default     = ""
}

variable "enable_s3_uploads" {
  description = "Enable S3 uploads for CTFd"
  type        = bool
  default     = true
}

# Redis Configuration
variable "enable_redis" {
  description = "Enable Redis for caching (requires separate Redis setup)"
  type        = bool
  default     = false
}

variable "redis_url" {
  description = "Redis URL for caching"
  type        = string
  default     = ""
}

# Logging Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "log_level" {
  description = "Log level for the application"
  type        = string
  default     = "INFO"
}

# CTFd Specific Configuration
variable "ctfd_secret_key" {
  description = "Secret key for CTFd sessions (will be auto-generated if empty)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ctfd_upload_folder" {
  description = "Upload folder path inside container"
  type        = string
  default     = "/var/uploads"
}

variable "ctfd_reverse_proxy" {
  description = "Enable reverse proxy mode for CTFd"
  type        = bool
  default     = true
}

variable "ctfd_mail_server" {
  description = "SMTP mail server for CTFd notifications"
  type        = string
  default     = ""
}

variable "ctfd_mail_port" {
  description = "SMTP mail server port"
  type        = number
  default     = 587
}

variable "ctfd_mail_username" {
  description = "SMTP mail username"
  type        = string
  default     = ""
}

variable "ctfd_mail_password" {
  description = "SMTP mail password"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ctfd_mail_tls" {
  description = "Enable TLS for SMTP"
  type        = bool
  default     = true
}

variable "ctfd_mail_ssl" {
  description = "Enable SSL for SMTP"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}