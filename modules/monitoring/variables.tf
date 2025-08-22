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

# SNS Configuration
variable "create_sns_topic" {
  description = "Create SNS topic for alerts"
  type        = bool
  default     = true
}

variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = ""
}

variable "notification_endpoints" {
  description = "List of email addresses for notifications"
  type        = list(string)
  default     = []
}

variable "external_notification_endpoints" {
  description = "List of external notification endpoints (Lambda, SQS, HTTP/S, etc.)"
  type = list(object({
    protocol = string
    endpoint = string
    delivery_policy = optional(object({
      num_retries           = optional(number, 3)
      num_max_delay_retries = optional(number, 0)
      min_delay_target      = optional(number, 20)
      max_delay_target      = optional(number, 20)
    }))
  }))
  default = []
}

# Dashboard Configuration
variable "create_dashboard" {
  description = "Create CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = ""
}

# Resource ARNs for monitoring
variable "load_balancer_arn_suffix" {
  description = "ARN suffix of the load balancer"
  type        = string
}

variable "target_group_arn_suffix" {
  description = "ARN suffix of the target group"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "db_instance_id" {
  description = "RDS instance identifier"
  type        = string
}

variable "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

# Alarm Configuration
variable "enable_billing_alerts" {
  description = "Enable billing alerts"
  type        = bool
  default     = false
}

variable "billing_alert_threshold" {
  description = "Billing alert threshold in USD"
  type        = number
  default     = 100
}

variable "enable_custom_metrics" {
  description = "Enable custom application metrics"
  type        = bool
  default     = false
}

# Log Insights Configuration
variable "enable_log_insights" {
  description = "Enable CloudWatch Log Insights queries"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Log retention period in days"
  type        = number
  default     = 7
}

# X-Ray Configuration
variable "enable_xray" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = false
}

variable "xray_sampling_rate" {
  description = "X-Ray sampling rate"
  type        = number
  default     = 0.1
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}