# Generate random password for database
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store database credentials in Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "${var.project_name}/${var.environment}/database"
  description             = "Database credentials for ${var.project_name} ${var.environment}"
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-credentials"
  })
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_password.result
    engine   = var.db_engine
    host     = aws_db_instance.main.endpoint
    port     = var.db_port
    dbname   = var.db_name
  })

  depends_on = [aws_db_instance.main]
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.database_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-subnet-group"
  })
}

# DB Parameter Group
resource "aws_db_parameter_group" "main" {
  count  = var.create_db_parameter_group ? 1 : 0
  family = "${var.db_engine}${split(".", var.db_engine_version)[0]}.${split(".", var.db_engine_version)[1]}"
  name   = "${var.project_name}-${var.environment}-db-params"

  # MySQL optimizations for CTFd
  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  parameter {
    name  = "max_connections"
    value = "200"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
  }

  parameter {
    name  = "long_query_time"
    value = "2"
  }

  parameter {
    name  = "log_queries_not_using_indexes"
    value = "1"
  }

  parameter {
    name  = "innodb_log_file_size"
    value = "134217728"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-parameter-group"
  })
}

# DB Option Group (if needed)
resource "aws_db_option_group" "main" {
  count                    = var.create_db_option_group ? 1 : 0
  name                     = "${var.project_name}-${var.environment}-db-options"
  option_group_description = "Option group for ${var.project_name} ${var.environment}"
  engine_name              = var.db_engine
  major_engine_version     = "${split(".", var.db_engine_version)[0]}.${split(".", var.db_engine_version)[1]}"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-option-group"
  })
}

# Enhanced Monitoring Role
resource "aws_iam_role" "rds_enhanced_monitoring" {
  count = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.project_name}-${var.environment}-rds-enhanced-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  count      = var.create_monitoring_role && var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.rds_enhanced_monitoring[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-db"

  # Engine
  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  # Database
  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result
  port     = var.db_port

  # Storage
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  storage_type          = var.db_storage_type
  storage_encrypted     = var.storage_encrypted
  kms_key_id            = var.kms_key_id

  # Network
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = var.database_security_group_ids
  publicly_accessible    = var.publicly_accessible
  multi_az               = var.multi_az

  # Parameter and Option Groups
  parameter_group_name = var.create_db_parameter_group ? aws_db_parameter_group.main[0].name : null
  option_group_name    = var.create_db_option_group ? aws_db_option_group.main[0].name : null

  # Backup
  backup_retention_period   = var.enable_backups ? var.backup_retention_period : 0
  backup_window             = var.backup_window
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = var.enable_backups ? var.skip_final_snapshot : true
  final_snapshot_identifier = var.enable_backups && !var.skip_final_snapshot ? "${var.project_name}-${var.environment}-db-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}" : null

  # Maintenance
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  apply_immediately          = var.apply_immediately

  # Deletion protection
  deletion_protection = var.enable_deletion_protection

  # Monitoring
  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.create_monitoring_role && var.monitoring_interval > 0 ? aws_iam_role.rds_enhanced_monitoring[0].arn : null

  # Performance Insights
  performance_insights_enabled          = var.enable_performance_insights
  performance_insights_retention_period = var.enable_performance_insights ? var.performance_insights_retention_period : null

  # Logging
  enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db"
  })

}

# CloudWatch Alarms for RDS
resource "aws_cloudwatch_metric_alarm" "database_cpu" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-db-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors RDS CPU utilization"
  alarm_actions       = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "database_connections" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-db-connection-count"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "180"
  alarm_description   = "This metric monitors RDS connection count"
  alarm_actions       = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "database_free_storage" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-db-free-storage-space"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = "300"
  statistic           = "Average"
  threshold           = "2000000000" # 2GB in bytes
  alarm_description   = "This metric monitors RDS free storage space"
  alarm_actions       = []

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.main.id
  }

  tags = var.tags
}