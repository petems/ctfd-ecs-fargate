output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_port" {
  description = "Redis port"
  value       = aws_elasticache_replication_group.redis.port
}

output "redis_auth_token" {
  description = "Redis auth token (if configured)"
  value       = var.redis_auth_token
  sensitive   = true
}

output "redis_url" {
  description = "Redis connection URL"
  value       = var.redis_auth_token != "" ? "redis://:${var.redis_auth_token}@${aws_elasticache_replication_group.redis.primary_endpoint_address}:${aws_elasticache_replication_group.redis.port}" : "redis://${aws_elasticache_replication_group.redis.primary_endpoint_address}:${aws_elasticache_replication_group.redis.port}"
  sensitive   = true
}

output "redis_security_group_id" {
  description = "Redis security group ID"
  value       = aws_security_group.redis.id
}

output "redis_subnet_group_name" {
  description = "Redis subnet group name"
  value       = aws_elasticache_subnet_group.redis.name
}

output "redis_parameter_group_name" {
  description = "Redis parameter group name"
  value       = aws_elasticache_parameter_group.redis.name
}

output "redis_replication_group_id" {
  description = "Redis replication group ID"
  value       = aws_elasticache_replication_group.redis.id
}
