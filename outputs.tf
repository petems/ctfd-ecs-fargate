# Root module outputs - expose key infrastructure information

# Application Access
output "application_url" {
  description = "URL to access the CTFd application"
  value       = module.load_balancer.application_url
}

output "application_domain" {
  description = "Domain name for the CTFd application"
  value       = var.domain_name
}

# Load Balancer Information
output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.load_balancer.load_balancer_dns_name
}

output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.load_balancer.load_balancer_arn
}

output "load_balancer_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = module.load_balancer.load_balancer_zone_id
}

# DNS Information
output "route53_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = module.load_balancer.route53_zone_id
}

output "route53_name_servers" {
  description = "Name servers for the Route53 hosted zone (configure these in your domain registrar)"
  value       = module.load_balancer.route53_zone_name_servers
}

# SSL Certificate
output "acm_certificate_arn" {
  description = "ARN of the ACM SSL certificate"
  value       = module.load_balancer.acm_certificate_arn
}

# Database Information
output "database_endpoint" {
  description = "RDS database endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

output "database_secret_arn" {
  description = "ARN of the database credentials secret in Secrets Manager"
  value       = module.database.secrets_manager_secret_arn
}

# ECS Information
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.ecs_service_name
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = module.ecs.ecs_cluster_arn
}

# Storage Information
output "s3_bucket_name" {
  description = "Name of the S3 bucket for file uploads"
  value       = module.storage.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for file uploads"
  value       = module.storage.s3_bucket_arn
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.storage.ecr_repository_url
}

# Networking Information
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

# Security Information
output "security_groups" {
  description = "Security group information"
  value = {
    alb_security_group_id       = module.security.alb_security_group_id
    ecs_security_group_id       = module.security.ecs_tasks_security_group_id
    database_security_group_id  = module.security.database_security_group_id
  }
}

# Monitoring Information
output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch dashboard"
  value       = module.monitoring.dashboard_url
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = module.monitoring.sns_topic_arn
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group for the application"
  value       = module.ecs.cloudwatch_log_group_name
}

# Deployment Information
output "deployment_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

# Container Information
output "container_image" {
  description = "Container image being used"
  value       = var.ctfd_container_image
}

# Quick Setup Information
output "setup_instructions" {
  description = "Quick setup instructions"
  value = <<EOF
CTFd Infrastructure Deployment Complete!

1. Application Access:
   - URL: ${module.load_balancer.application_url}
   - It may take 5-10 minutes for the application to be fully available

2. DNS Setup (if using external domain registrar):
   - Configure these name servers in your domain registrar:
   ${join("\n   ", module.load_balancer.route53_zone_name_servers != null ? module.load_balancer.route53_zone_name_servers : ["N/A - Route53 zone not created"])}

3. Monitoring:
   - CloudWatch Dashboard: ${module.monitoring.dashboard_url != null ? module.monitoring.dashboard_url : "Not created"}
   - Log Group: ${module.ecs.cloudwatch_log_group_name}

4. Container Management:
   - ECR Repository: ${module.storage.ecr_repository_url != null ? module.storage.ecr_repository_url : "Not created"}
   - ECS Cluster: ${module.ecs.ecs_cluster_name}
   - ECS Service: ${module.ecs.ecs_service_name}

5. Database:
   - Credentials stored in AWS Secrets Manager: ${module.database.secrets_manager_secret_name}

6. File Storage:
   - S3 Bucket: ${module.storage.s3_bucket_name != null ? module.storage.s3_bucket_name : "Not created"}

For troubleshooting, check the ECS service logs in CloudWatch.
EOF
}