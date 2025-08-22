output "db_instance_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.main.id
}

output "db_instance_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "db_instance_hosted_zone_id" {
  description = "RDS instance hosted zone ID"
  value       = aws_db_instance.main.hosted_zone_id
}

output "db_instance_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "db_instance_name" {
  description = "RDS instance database name"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "RDS instance username"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "db_subnet_group_id" {
  description = "DB subnet group ID"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "DB subnet group ARN"
  value       = aws_db_subnet_group.main.arn
}

output "db_parameter_group_id" {
  description = "DB parameter group ID"
  value       = var.create_db_parameter_group ? aws_db_parameter_group.main[0].id : null
}

output "db_option_group_id" {
  description = "DB option group ID"
  value       = var.create_db_option_group ? aws_db_option_group.main[0].id : null
}

output "secrets_manager_secret_id" {
  description = "Secrets Manager secret ID for database credentials"
  value       = aws_secretsmanager_secret.db_credentials.id
}

output "secrets_manager_secret_arn" {
  description = "Secrets Manager secret ARN for database credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "secrets_manager_secret_name" {
  description = "Secrets Manager secret name for database credentials"
  value       = aws_secretsmanager_secret.db_credentials.name
}

output "enhanced_monitoring_iam_role_arn" {
  description = "Enhanced monitoring IAM role ARN"
  value       = var.create_monitoring_role && var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
}

output "cloudwatch_metric_alarm_ids" {
  description = "CloudWatch metric alarm IDs"
  value = {
    cpu_utilization  = length(aws_cloudwatch_metric_alarm.database_cpu) > 0 ? aws_cloudwatch_metric_alarm.database_cpu[0].id : null
    connection_count = length(aws_cloudwatch_metric_alarm.database_connections) > 0 ? aws_cloudwatch_metric_alarm.database_connections[0].id : null
    free_storage     = length(aws_cloudwatch_metric_alarm.database_free_storage) > 0 ? aws_cloudwatch_metric_alarm.database_free_storage[0].id : null
  }
}