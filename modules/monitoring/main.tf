# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  count = (var.create_sns_topic && var.create_dashboard) ? 1 : 0
  name  = var.sns_topic_name != "" ? var.sns_topic_name : "${var.project_name}-${var.environment}-alerts"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alerts"
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "alerts" {
  count = (var.create_sns_topic && var.create_dashboard) ? 1 : 0
  arn   = aws_sns_topic.alerts[0].arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.alerts[0].arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# Email Subscriptions
resource "aws_sns_topic_subscription" "email" {
  count     = (var.create_sns_topic && var.create_dashboard) ? length(var.notification_endpoints) : 0
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = var.notification_endpoints[count.index]
}

# Additional SNS Subscriptions (for external integrations)
resource "aws_sns_topic_subscription" "external" {
  count     = (var.create_sns_topic && var.create_dashboard) ? length(var.external_notification_endpoints) : 0
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = var.external_notification_endpoints[count.index].protocol
  endpoint  = var.external_notification_endpoints[count.index].endpoint

  # Optional endpoint configuration
  delivery_policy = var.external_notification_endpoints[count.index].delivery_policy != null ? jsonencode({
    healthy_retry_policy = {
      num_retries           = var.external_notification_endpoints[count.index].delivery_policy.num_retries
      num_max_delay_retries = var.external_notification_endpoints[count.index].delivery_policy.num_max_delay_retries
      min_delay_target      = var.external_notification_endpoints[count.index].delivery_policy.min_delay_target
      max_delay_target      = var.external_notification_endpoints[count.index].delivery_policy.max_delay_target
    }
  }) : null
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  count          = var.create_dashboard ? 1 : 0
  dashboard_name = var.dashboard_name != "" ? var.dashboard_name : "${var.project_name}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.load_balancer_arn_suffix],
            [".", "TargetResponseTime", ".", "."],
            [".", "HTTPCode_Target_2XX_Count", ".", "."],
            [".", "HTTPCode_ELB_5XX_Count", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Load Balancer Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", var.ecs_service_name, "ClusterName", var.ecs_cluster_name],
            [".", "MemoryUtilization", ".", ".", ".", "."],
            [".", "RunningTaskCount", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECS Service Metrics"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.db_instance_id],
            [".", "DatabaseConnections", ".", "."],
            [".", "FreeStorageSpace", ".", "."],
            [".", "ReadLatency", ".", "."],
            [".", "WriteLatency", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "RDS Database Metrics"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 18
        width  = 24
        height = 6
        properties = {
          query  = "SOURCE '${var.cloudwatch_log_group_name}'\n| fields @timestamp, @message\n| sort @timestamp desc\n| limit 100"
          region = var.aws_region
          title  = "Recent Application Logs"
          view   = "table"
        }
      }
    ]
  })
}

# Billing Alert (if enabled)
resource "aws_cloudwatch_metric_alarm" "billing" {
  count               = var.enable_billing_alerts ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-billing-alert"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "86400"
  statistic           = "Maximum"
  threshold           = var.billing_alert_threshold
  alarm_description   = "This metric monitors AWS billing charges"
  alarm_actions       = var.create_sns_topic ? [aws_sns_topic.alerts[0].arn] : []

  dimensions = {
    Currency = "USD"
  }

  tags = var.tags
}

# Custom CloudWatch Log Group for application metrics
resource "aws_cloudwatch_log_group" "custom_metrics" {
  count             = var.enable_custom_metrics ? 1 : 0
  name              = "/aws/lambda/${var.project_name}-${var.environment}-custom-metrics"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-custom-metrics"
  })
}

# X-Ray Service Map (if enabled)
resource "aws_xray_sampling_rule" "main" {
  count           = var.enable_xray ? 1 : 0
  rule_name       = "${var.project_name}-${var.environment}-sampling"
  priority        = 9000
  version         = 1
  reservoir_size  = 1
  fixed_rate      = var.xray_sampling_rate
  url_path        = "*"
  host            = "*"
  http_method     = "*"
  service_type    = "*"
  service_name    = "*"
  resource_arn    = "*"

  tags = var.tags
}

# CloudWatch Log Insights Saved Queries
resource "aws_cloudwatch_query_definition" "error_logs" {
  count = var.enable_log_insights ? 1 : 0
  name  = "${var.project_name}-${var.environment}-error-logs"

  log_group_names = [var.cloudwatch_log_group_name]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /ERROR/
| sort @timestamp desc
| limit 100
EOF
}

resource "aws_cloudwatch_query_definition" "slow_requests" {
  count = var.enable_log_insights ? 1 : 0
  name  = "${var.project_name}-${var.environment}-slow-requests"

  log_group_names = [var.cloudwatch_log_group_name]

  query_string = <<EOF
fields @timestamp, @message
| filter @message like /slow/
| stats count() by bin(5m)
| sort @timestamp desc
EOF
}

resource "aws_cloudwatch_query_definition" "request_volume" {
  count = var.enable_log_insights ? 1 : 0
  name  = "${var.project_name}-${var.environment}-request-volume"

  log_group_names = [var.cloudwatch_log_group_name]

  query_string = <<EOF
fields @timestamp
| stats count() by bin(5m)
| sort @timestamp desc
EOF
}