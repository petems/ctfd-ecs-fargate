output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value       = var.create_sns_topic ? aws_sns_topic.alerts[0].arn : null
}

output "sns_topic_name" {
  description = "Name of the SNS topic for alerts"
  value       = var.create_sns_topic ? aws_sns_topic.alerts[0].name : null
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = var.create_dashboard ? "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}" : null
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.main[0].dashboard_name : null
}

output "log_insights_queries" {
  description = "CloudWatch Log Insights saved queries"
  value = var.enable_log_insights ? {
    error_logs     = aws_cloudwatch_query_definition.error_logs[0].name
    slow_requests  = aws_cloudwatch_query_definition.slow_requests[0].name
    request_volume = aws_cloudwatch_query_definition.request_volume[0].name
  } : null
}

output "billing_alarm_arn" {
  description = "ARN of the billing alarm"
  value       = var.enable_billing_alerts ? aws_cloudwatch_metric_alarm.billing[0].arn : null
}

output "xray_sampling_rule_arn" {
  description = "ARN of the X-Ray sampling rule"
  value       = var.enable_xray ? aws_xray_sampling_rule.main[0].arn : null
}

output "custom_metrics_log_group" {
  description = "Custom metrics log group name"
  value       = var.enable_custom_metrics ? aws_cloudwatch_log_group.custom_metrics[0].name : null
}