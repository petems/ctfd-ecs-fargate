output "ecs_cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_id" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.ctfd.id
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.ctfd.name
}

output "ecs_service_cluster" {
  description = "Amazon Resource Name (ARN) of cluster which the service runs on"
  value       = aws_ecs_service.ctfd.cluster
}

output "ecs_service_desired_count" {
  description = "Number of instances of the task definition"
  value       = aws_ecs_service.ctfd.desired_count
}

output "ecs_task_definition_arn" {
  description = "Full ARN of the Task Definition"
  value       = aws_ecs_task_definition.ctfd.arn
}

output "ecs_task_definition_family" {
  description = "Family of the Task Definition"
  value       = aws_ecs_task_definition.ctfd.family
}

output "ecs_task_definition_revision" {
  description = "Revision of the task definition"
  value       = aws_ecs_task_definition.ctfd.revision
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_logs.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.ecs_logs.arn
}

output "autoscaling_target_resource_id" {
  description = "Resource ID of the autoscaling target"
  value       = var.enable_auto_scaling ? aws_appautoscaling_target.ecs_target[0].resource_id : null
}

output "cpu_autoscaling_policy_arn" {
  description = "ARN of the CPU autoscaling policy"
  value       = var.enable_auto_scaling ? aws_appautoscaling_policy.ecs_cpu_policy[0].arn : null
}

output "memory_autoscaling_policy_arn" {
  description = "ARN of the memory autoscaling policy"
  value       = var.enable_auto_scaling ? aws_appautoscaling_policy.ecs_memory_policy[0].arn : null
}

output "ctfd_secret_key_secret_arn" {
  description = "ARN of the CTFd secret key secret"
  value       = aws_secretsmanager_secret.ctfd_secret_key.arn
}

output "cloudwatch_metric_alarm_ids" {
  description = "CloudWatch metric alarm IDs"
  value = {
    cpu_high      = aws_cloudwatch_metric_alarm.ecs_service_cpu_high.id
    memory_high   = aws_cloudwatch_metric_alarm.ecs_service_memory_high.id
    task_count    = aws_cloudwatch_metric_alarm.ecs_service_task_count.id
  }
}