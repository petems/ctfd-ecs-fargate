# Monitoring Module

This module provides comprehensive monitoring and alerting for the CTFd infrastructure using CloudWatch, SNS, and optional third-party integrations.

## Features

### CloudWatch Integration
- **Dashboard**: Unified view of ALB, ECS, and RDS metrics
- **Log Insights**: Pre-configured queries for error analysis and performance monitoring
- **Custom Metrics**: Support for application-specific metrics
- **Alarms**: Proactive monitoring with configurable thresholds

### Notification System
- **SNS Topics**: Centralized alerting infrastructure
- **Email Notifications**: Direct email alerts for critical events
- **External Integrations**: Flexible support for webhooks, Lambda functions, and third-party services
- **Delivery Policies**: Configurable retry and delivery settings

### Observability
- **Log Aggregation**: Centralized logging with retention policies
- **Performance Monitoring**: Application and infrastructure metrics
- **Cost Monitoring**: Optional billing alerts and cost tracking
- **X-Ray Integration**: Distributed tracing support (optional)

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  project_name = "ctfd"
  environment  = "prod"
  aws_region   = "us-west-2"

  # Resource references for monitoring
  load_balancer_arn_suffix   = module.load_balancer.load_balancer_arn_suffix
  target_group_arn_suffix    = module.load_balancer.target_group_arn_suffix
  ecs_cluster_name           = module.ecs.ecs_cluster_name
  ecs_service_name           = module.ecs.ecs_service_name
  db_instance_id             = module.database.db_instance_id
  cloudwatch_log_group_name  = module.ecs.cloudwatch_log_group_name

  # Notification configuration
  notification_endpoints = ["admin@example.com", "ops@example.com"]
  
  # External integrations
  external_notification_endpoints = [
    {
      protocol = "https"
      endpoint = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
    },
    {
      protocol = "lambda"
      endpoint = "arn:aws:lambda:region:account:function:custom-alerting"
      delivery_policy = {
        num_retries           = 5
        min_delay_target      = 30
        max_delay_target      = 600
      }
    }
  ]

  # Features
  enable_billing_alerts   = true
  billing_alert_threshold = 500
  enable_log_insights     = true
  log_retention_days      = 30

  tags = {
    Owner = "platform-team"
  }
}
```

## Dashboard Components

### Load Balancer Metrics
- Request count and response times
- HTTP status codes (2xx, 4xx, 5xx)
- Target health and connection metrics
- SSL certificate expiration monitoring

### ECS Service Metrics
- CPU and memory utilization
- Running task count and service health
- Task placement and scaling events
- Container startup and failure rates

### Database Metrics
- CPU utilization and connection count
- Storage usage and I/O performance
- Query performance and slow queries
- Backup and maintenance events

### Application Logs
- Real-time log streaming
- Error detection and categorization
- Performance analysis queries
- Security event monitoring

## Alert Configuration

### Default Alarms
- **High CPU**: ECS tasks or RDS > 80%
- **High Memory**: ECS tasks > 85%
- **Low Healthy Targets**: ALB healthy targets < 1
- **High Response Time**: ALB response time > 2 seconds
- **Database Connections**: RDS connections > 80% of max
- **Storage Space**: RDS free storage < 2GB

### Custom Alarms
Add application-specific monitoring:

```hcl
resource "aws_cloudwatch_metric_alarm" "custom_metric" {
  alarm_name          = "${var.project_name}-${var.environment}-custom-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CustomMetric"
  namespace           = "CTFd/Application"
  period              = "300"
  statistic           = "Average"
  threshold           = "100"
  alarm_actions       = [module.monitoring.sns_topic_arn]
}
```

## External Integrations

### Supported Protocols
- **Email**: Direct email notifications
- **HTTPS**: Webhook integrations (Slack, Discord, PagerDuty)
- **Lambda**: Custom notification processing
- **SQS**: Queue-based notification handling
- **SMS**: Text message alerts (additional charges apply)

### Example Configurations

#### Slack Integration
```hcl
external_notification_endpoints = [
  {
    protocol = "https"
    endpoint = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
  }
]
```

#### Custom Lambda Handler
```hcl
external_notification_endpoints = [
  {
    protocol = "lambda"
    endpoint = "arn:aws:lambda:us-west-2:123456789012:function:alert-processor"
    delivery_policy = {
      num_retries           = 3
      num_max_delay_retries = 2
      min_delay_target      = 20
      max_delay_target      = 300
    }
  }
]
```

#### PagerDuty Integration
```hcl
external_notification_endpoints = [
  {
    protocol = "https"
    endpoint = "https://events.pagerduty.com/integration/YOUR-INTEGRATION-KEY/enqueue"
  }
]
```

## Log Insights Queries

### Pre-configured Queries

1. **Error Analysis**
   ```sql
   fields @timestamp, @message
   | filter @message like /ERROR/
   | sort @timestamp desc
   | limit 100
   ```

2. **Performance Monitoring**
   ```sql
   fields @timestamp, @message
   | filter @message like /slow/
   | stats count() by bin(5m)
   ```

3. **Request Volume**
   ```sql
   fields @timestamp
   | stats count() by bin(5m)
   | sort @timestamp desc
   ```

### Custom Queries
Add application-specific log analysis:

```hcl
resource "aws_cloudwatch_query_definition" "ctf_submissions" {
  name = "${var.project_name}-${var.environment}-ctf-submissions"
  
  log_group_names = [var.cloudwatch_log_group_name]
  
  query_string = <<EOF
fields @timestamp, @message
| filter @message like /submission/
| stats count() by bin(1h)
| sort @timestamp desc
EOF
}
```

## Cost Monitoring

### Billing Alerts
Monitor AWS costs to prevent unexpected charges:

```hcl
enable_billing_alerts      = true
billing_alert_threshold    = 100  # USD
```

### Cost Optimization
- **Log Retention**: Automatic cleanup of old logs
- **Metric Filters**: Reduce custom metric charges
- **Dashboard Optimization**: Efficient metric queries

## Advanced Features

### X-Ray Tracing
Enable distributed tracing for performance analysis:

```hcl
enable_xray         = true
xray_sampling_rate  = 0.1  # 10% sampling
```

### Custom Metrics
Application-specific metrics collection:

```hcl
enable_custom_metrics = true
```

## Troubleshooting

### Common Issues

1. **SNS Delivery Failures**
   - Verify endpoint URLs and permissions
   - Check delivery policies and retry settings
   - Monitor SNS topic metrics

2. **Dashboard Not Loading**
   - Verify IAM permissions for CloudWatch
   - Check resource ARN references
   - Ensure metrics are being generated

3. **Missing Alerts**
   - Confirm alarm thresholds are appropriate
   - Verify SNS topic subscriptions
   - Check alarm state and evaluation periods

### Debugging Commands

```bash
# Check SNS topic status
aws sns get-topic-attributes --topic-arn <topic-arn>

# Test SNS delivery
aws sns publish --topic-arn <topic-arn> --message "Test message"

# View CloudWatch metrics
aws cloudwatch get-metric-statistics --namespace AWS/ECS --metric-name CPUUtilization

# Check alarm history
aws cloudwatch describe-alarm-history --alarm-name <alarm-name>
```

## Security Considerations

- **IAM Permissions**: Least-privilege access for monitoring services
- **SNS Encryption**: Optional encryption for sensitive notifications
- **VPC Endpoints**: Private connectivity for CloudWatch APIs
- **Access Logging**: Audit trail for monitoring configuration changes

## Best Practices

- **Baseline Metrics**: Establish normal operating ranges
- **Alert Fatigue**: Tune thresholds to reduce false positives
- **Escalation**: Implement multiple notification tiers
- **Documentation**: Maintain runbooks for common alerts
- **Regular Review**: Periodically assess monitoring effectiveness