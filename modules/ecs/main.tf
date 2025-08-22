# Generate secret key for CTFd if not provided
resource "random_password" "ctfd_secret_key" {
  count   = var.ctfd_secret_key == "" ? 1 : 0
  length  = 32
  special = true
}

# Store CTFd secret key in Secrets Manager
resource "aws_secretsmanager_secret" "ctfd_secret_key" {
  name                    = "${var.project_name}/${var.environment}/ctfd-secret-key"
  description             = "CTFd secret key for ${var.project_name} ${var.environment}"
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ctfd-secret-key"
  })
}

resource "aws_secretsmanager_secret_version" "ctfd_secret_key" {
  secret_id     = aws_secretsmanager_secret.ctfd_secret_key.id
  secret_string = var.ctfd_secret_key != "" ? var.ctfd_secret_key : random_password.ctfd_secret_key[0].result
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecs-logs"
  })
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}"

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_logs.name
      }
    }
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-cluster"
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "ctfd" {
  family                   = "${var.project_name}-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.ecs_task_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name  = "ctfd"
      image = var.container_image

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = concat([
        {
          name  = "UPLOAD_FOLDER"
          value = var.ctfd_upload_folder
        },
        {
          name  = "REVERSE_PROXY"
          value = var.ctfd_reverse_proxy ? "true" : "false"
        },
        {
          name  = "LOG_FOLDER"
          value = "/var/log/CTFd"
        },
        {
          name  = "AWS_DEFAULT_REGION"
          value = var.aws_region
        }
        ], var.enable_s3_uploads && var.s3_bucket_name != "" ? [
        {
          name  = "UPLOAD_PROVIDER"
          value = "s3"
        },
        {
          name  = "AWS_S3_BUCKET"
          value = var.s3_bucket_name
        },
        {
          name  = "AWS_S3_REGION"
          value = var.aws_region
        }
        ] : [], var.enable_redis && var.redis_url != "" ? [
        {
          name  = "REDIS_URL"
          value = var.redis_url
        }
        ] : [], var.ctfd_mail_server != "" ? [
        {
          name  = "MAIL_SERVER"
          value = var.ctfd_mail_server
        },
        {
          name  = "MAIL_PORT"
          value = tostring(var.ctfd_mail_port)
        },
        {
          name  = "MAIL_USERNAME"
          value = var.ctfd_mail_username
        },
        {
          name  = "MAIL_PASSWORD"
          value = var.ctfd_mail_password
        },
        {
          name  = "MAIL_TLS"
          value = var.ctfd_mail_tls ? "true" : "false"
        },
        {
          name  = "MAIL_SSL"
          value = var.ctfd_mail_ssl ? "true" : "false"
        }
      ] : [])

      secrets = [
        {
          name      = "DATABASE_URL"
          valueFrom = var.database_secret_arn
        },
        {
          name      = "SECRET_KEY"
          valueFrom = aws_secretsmanager_secret.ctfd_secret_key.arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:${var.container_port}/healthcheck || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      essential = true
    }
  ])

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-task-definition"
  })
}

# ECS Service
resource "aws_ecs_service" "ctfd" {
  name            = "${var.project_name}-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ctfd.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  deployment_maximum_percent         = var.deployment_maximum_percent
  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent

  network_configuration {
    security_groups  = var.ecs_security_group_ids
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "ctfd"
    container_port   = var.container_port
  }

  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  enable_execute_command = var.enable_execute_command

  depends_on = [
    aws_ecs_task_definition.ctfd
  ]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-service"
  })

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Auto Scaling Target
resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.enable_auto_scaling ? 1 : 0
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.ctfd.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  tags = var.tags
}

# Auto Scaling Policy - CPU
resource "aws_appautoscaling_policy" "ecs_cpu_policy" {
  count              = var.enable_auto_scaling ? 1 : 0
  name               = "${var.project_name}-${var.environment}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value       = var.cpu_target_value
    scale_in_cooldown  = var.scale_down_cooldown
    scale_out_cooldown = var.scale_up_cooldown
  }
}

# Auto Scaling Policy - Memory
resource "aws_appautoscaling_policy" "ecs_memory_policy" {
  count              = var.enable_auto_scaling ? 1 : 0
  name               = "${var.project_name}-${var.environment}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value       = var.memory_target_value
    scale_in_cooldown  = var.scale_down_cooldown
    scale_out_cooldown = var.scale_up_cooldown
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "ecs_service_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ECS service CPU utilization"
  alarm_actions       = []

  dimensions = {
    ServiceName = aws_ecs_service.ctfd.name
    ClusterName = aws_ecs_cluster.main.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_memory_high" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "85"
  alarm_description   = "This metric monitors ECS service memory utilization"
  alarm_actions       = []

  dimensions = {
    ServiceName = aws_ecs_service.ctfd.name
    ClusterName = aws_ecs_cluster.main.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_service_task_count" {
  alarm_name          = "${var.project_name}-${var.environment}-ecs-task-count-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ECS service running task count"
  alarm_actions       = []

  dimensions = {
    ServiceName = aws_ecs_service.ctfd.name
    ClusterName = aws_ecs_cluster.main.name
  }

  tags = var.tags
}