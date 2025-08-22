variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "alb_port" {
  description = "Port for Application Load Balancer"
  type        = number
  default     = 80
}

variable "alb_ssl_port" {
  description = "SSL port for Application Load Balancer"
  type        = number
  default     = 443
}

variable "app_port" {
  description = "Port for the application"
  type        = number
  default     = 8000
}

variable "database_port" {
  description = "Port for the database"
  type        = number
  default     = 3306
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the load balancer"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "create_ecs_task_role" {
  description = "Create ECS task role"
  type        = bool
  default     = true
}

variable "create_ecs_execution_role" {
  description = "Create ECS task execution role"
  type        = bool
  default     = true
}

variable "s3_bucket_arn" {
  description = "ARN of S3 bucket for ECS task access"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}