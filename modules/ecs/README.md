# ECS Module

This module creates the ECS Fargate infrastructure to run CTFd containers with auto-scaling, monitoring, and proper integration with other AWS services.

## Architecture

```
ECS Cluster (Fargate) -> ECS Service -> Task Definition
                           |              |
                      Auto Scaling    CTFd Container
                           |              |
                    CloudWatch      CloudWatch Logs
```

## Features

- **ECS Fargate cluster** with Container Insights enabled
- **CTFd task definition** with optimized container configuration
- **ECS service** with health checks and load balancer integration
- **Auto-scaling** based on CPU and memory utilization
- **CloudWatch logging** and monitoring
- **Secrets management** integration
- **Health checks** for container reliability

## CTFd Container Configuration

Based on the official CTFd Docker Compose setup, the container is configured with:

- **Official CTFd image**: `ctfd/ctfd:latest` from Docker Hub
- **Environment variables**:
  - `UPLOAD_FOLDER`: Container path for uploads
  - `REVERSE_PROXY`: Enabled for ALB integration
  - `DATABASE_URL`: MySQL connection from Secrets Manager
  - `SECRET_KEY`: Application secret from Secrets Manager
  - S3 configuration (if enabled)
  - SMTP configuration (if provided)

## Usage

```hcl
module "ecs" {
  source = "./modules/ecs"

  project_name = "ctfd"
  environment  = "dev"
  aws_region   = "us-west-2"

  # Network Configuration
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  ecs_security_group_ids = [module.security.ecs_tasks_security_group_id]
  alb_target_group_arn  = module.load_balancer.target_group_arn

  # IAM Roles
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn          = module.security.ecs_task_role_arn

  # Container Configuration
  container_image  = "ctfd/ctfd:latest"
  container_cpu    = 512
  container_memory = 1024

  # Service Configuration
  desired_count = 2
  max_capacity  = 10
  min_capacity  = 1

  # Database Integration
  database_secret_arn = module.database.secrets_manager_secret_arn

  # S3 Integration
  enable_s3_uploads = true
  s3_bucket_name    = module.storage.s3_bucket_name

  # Auto Scaling
  enable_auto_scaling = true
  cpu_target_value    = 70
  memory_target_value = 80

  tags = {
    Owner = "devops"
  }
}
```

## Container Health Checks

The module configures comprehensive health checking:

- **Container health check**: HTTP endpoint on `/healthcheck`
- **Load balancer health check**: Configured in ALB target group
- **ECS service health check**: Grace period for startup

## Auto Scaling

Two scaling policies are configured:

1. **CPU-based scaling**: Targets 70% CPU utilization
2. **Memory-based scaling**: Targets 80% memory utilization

Scaling parameters:
- Scale-out cooldown: 5 minutes
- Scale-in cooldown: 5 minutes
- Maximum capacity: Configurable
- Minimum capacity: Configurable

## Monitoring & Alerting

CloudWatch alarms monitor:
- **High CPU utilization** (>85%)
- **High memory utilization** (>85%)
- **Low task count** (<1 running task)

## Secrets Management

The module integrates with AWS Secrets Manager for:
- **Database credentials**: Automatically retrieved from RDS module
- **CTFd secret key**: Auto-generated or provided
- **SMTP credentials**: Optional email configuration

## Production Considerations

- **Enable execute command** for debugging (disabled by default)
- **Container Insights** enabled for enhanced monitoring
- **Proper resource allocation** based on expected load
- **Multi-AZ deployment** via private subnets
- **Security group isolation** from database and load balancer modules

## Troubleshooting

Common issues and solutions:

1. **Container startup failures**: Check CloudWatch logs
2. **Health check failures**: Verify container port configuration
3. **Database connection issues**: Check security groups and secrets
4. **Auto-scaling not working**: Verify CloudWatch metrics and thresholds