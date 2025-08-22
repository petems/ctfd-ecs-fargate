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

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the load balancer"
  type        = list(string)
}

variable "alb_security_group_ids" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}

variable "create_route53_zone" {
  description = "Create Route53 hosted zone"
  type        = bool
  default     = true
}

variable "route53_zone_id" {
  description = "Route53 zone ID (if not creating a new zone)"
  type        = string
  default     = ""
}

variable "create_acm_certificate" {
  description = "Create ACM certificate"
  type        = bool
  default     = true
}

variable "acm_certificate_arn" {
  description = "ARN of existing ACM certificate"
  type        = string
  default     = ""
}

variable "certificate_subject_alternative_names" {
  description = "Subject Alternative Names for the certificate"
  type        = list(string)
  default     = []
}

# ALB Configuration
variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = ""
}

variable "alb_type" {
  description = "Type of load balancer"
  type        = string
  default     = "application"
}

variable "alb_internal" {
  description = "Whether the load balancer is internal"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for ALB"
  type        = bool
  default     = false
}

variable "idle_timeout" {
  description = "Connection idle timeout in seconds"
  type        = number
  default     = 60
}

variable "enable_http2" {
  description = "Enable HTTP/2 on ALB"
  type        = bool
  default     = true
}

variable "enable_cross_zone_load_balancing" {
  description = "Enable cross-zone load balancing"
  type        = bool
  default     = true
}

# Target Group Configuration
variable "target_group_name" {
  description = "Name of the target group"
  type        = string
  default     = ""
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 8000
}

variable "target_group_protocol" {
  description = "Protocol for the target group"
  type        = string
  default     = "HTTP"
}

variable "target_type" {
  description = "Type of targets (instance, ip, lambda)"
  type        = string
  default     = "ip"
}

variable "health_check_enabled" {
  description = "Enable health checks"
  type        = bool
  default     = true
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/healthcheck"
}

variable "health_check_protocol" {
  description = "Health check protocol"
  type        = string
  default     = "HTTP"
}

variable "health_check_interval" {
  description = "Health check interval in seconds"
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Health check timeout in seconds"
  type        = number
  default     = 5
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive successful health checks"
  type        = number
  default     = 2
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive failed health checks"
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "HTTP status codes for successful health checks"
  type        = string
  default     = "200"
}

# Listener Configuration
variable "enable_http_listener" {
  description = "Enable HTTP listener"
  type        = bool
  default     = true
}

variable "enable_https_listener" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = true
}

variable "http_port" {
  description = "HTTP port"
  type        = number
  default     = 80
}

variable "https_port" {
  description = "HTTPS port"
  type        = number
  default     = 443
}

variable "ssl_policy" {
  description = "SSL security policy"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "redirect_http_to_https" {
  description = "Redirect HTTP traffic to HTTPS"
  type        = bool
  default     = true
}

# Access Logs Configuration
variable "enable_access_logs" {
  description = "Enable ALB access logs"
  type        = bool
  default     = false
}

variable "access_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
  default     = ""
}

variable "access_logs_prefix" {
  description = "S3 prefix for ALB access logs"
  type        = string
  default     = "alb-access-logs"
}

# WAF Configuration
variable "enable_waf" {
  description = "Enable AWS WAF v2 association"
  type        = bool
  default     = false
}

variable "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}