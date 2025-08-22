output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "ecs_tasks_security_group_id" {
  description = "ID of the ECS tasks security group"
  value       = aws_security_group.ecs_tasks.id
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = aws_security_group.database.id
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = aws_security_group.vpc_endpoints.id
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = var.create_ecs_execution_role ? aws_iam_role.ecs_task_execution_role[0].arn : null
}

output "ecs_task_execution_role_name" {
  description = "Name of the ECS task execution role"
  value       = var.create_ecs_execution_role ? aws_iam_role.ecs_task_execution_role[0].name : null
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = var.create_ecs_task_role ? aws_iam_role.ecs_task_role[0].arn : null
}

output "ecs_task_role_name" {
  description = "Name of the ECS task role"
  value       = var.create_ecs_task_role ? aws_iam_role.ecs_task_role[0].name : null
}