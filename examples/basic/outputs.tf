output "ctfd_url" {
  description = "URL of the CTFd application"
  value       = "https://${module.ctfd.domain_name}"
}

output "database_endpoint" {
  description = "RDS database endpoint"
  value       = module.ctfd.database_endpoint
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = module.ctfd.load_balancer_dns
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ctfd.ecs_cluster_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for file uploads"
  value       = module.ctfd.s3_bucket_name
}
