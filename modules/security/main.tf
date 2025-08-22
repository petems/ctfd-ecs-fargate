# Security Group for Application Load Balancer
resource "aws_security_group" "alb" {
  name_prefix = "${var.project_name}-${var.environment}-alb-"
  vpc_id      = var.vpc_id
  description = "Security group for Application Load Balancer"

  # HTTP inbound
  ingress {
    from_port   = var.alb_port
    to_port     = var.alb_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTP inbound traffic"
  }

  # HTTPS inbound
  ingress {
    from_port   = var.alb_ssl_port
    to_port     = var.alb_ssl_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
    description = "HTTPS inbound traffic"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${var.project_name}-${var.environment}-ecs-tasks-"
  vpc_id      = var.vpc_id
  description = "Security group for ECS tasks"

  # Application port inbound from ALB
  ingress {
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
    description     = "Application port from ALB"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ecs-tasks-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for RDS Database
resource "aws_security_group" "database" {
  name_prefix = "${var.project_name}-${var.environment}-database-"
  vpc_id      = var.vpc_id
  description = "Security group for RDS database"

  # Database port inbound from ECS tasks
  ingress {
    from_port       = var.database_port
    to_port         = var.database_port
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
    description     = "Database access from ECS tasks"
  }

  # No outbound rules needed for RDS

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-database-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Security Group for VPC Endpoints (optional)
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.project_name}-${var.environment}-vpc-endpoints-"
  vpc_id      = var.vpc_id
  description = "Security group for VPC endpoints"

  # HTTPS inbound from VPC
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
    description = "HTTPS from VPC"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ECS Task Execution Role
resource "aws_iam_role" "ecs_task_execution_role" {
  count = var.create_ecs_execution_role ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  count      = var.create_ecs_execution_role ? 1 : 0
  role       = aws_iam_role.ecs_task_execution_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Additional policy for Secrets Manager access
resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  count = var.create_ecs_execution_role ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ecs-execution-secrets"
  role  = aws_iam_role.ecs_task_execution_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:${var.project_name}/${var.environment}/*"
        ]
      }
    ]
  })
}

# ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  count = var.create_ecs_task_role ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# S3 access policy for ECS task role
resource "aws_iam_role_policy" "ecs_task_s3_policy" {
  count = var.create_ecs_task_role && var.s3_bucket_arn != "" ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ecs-task-s3-policy"
  role  = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${var.s3_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          var.s3_bucket_arn
        ]
      }
    ]
  })
}

# CloudWatch Logs policy for ECS task role
resource "aws_iam_role_policy" "ecs_task_logs_policy" {
  count = var.create_ecs_task_role ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ecs-task-logs-policy"
  role  = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:*:*:log-group:/ecs/${var.project_name}-${var.environment}/*"
        ]
      }
    ]
  })
}

# Secrets Manager policy for ECS task role
resource "aws_iam_role_policy" "ecs_task_secrets_policy" {
  count = var.create_ecs_task_role ? 1 : 0
  name  = "${var.project_name}-${var.environment}-ecs-task-secrets-policy"
  role  = aws_iam_role.ecs_task_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:*:*:secret:${var.project_name}/${var.environment}/*"
        ]
      }
    ]
  })
}