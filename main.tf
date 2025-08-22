# Main Terraform configuration for CTFd ECS Fargate deployment
# This file orchestrates all the modules to create a complete infrastructure

# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  single_nat_gateway    = var.environment == "dev" ? true : false # Cost optimization for dev

  # BYO Resource Support
  existing_vpc_id              = var.existing_vpc_id
  existing_public_subnet_ids   = var.existing_public_subnet_ids
  existing_private_subnet_ids  = var.existing_private_subnet_ids
  existing_database_subnet_ids = var.existing_database_subnet_ids

  tags = local.common_tags
}

# Security Module
module "security" {
  source = "./modules/security"

  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.networking.vpc_id
  vpc_cidr_block = module.networking.vpc_cidr_block
  app_port       = var.ctfd_container_port
  s3_bucket_arn  = module.storage.s3_bucket_arn

  tags = local.common_tags
}

# Storage Module
module "storage" {
  source = "./modules/storage"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  create_ecr_repository = var.create_ecr_repository
  s3_force_destroy      = var.environment == "dev" ? true : false # Allow destruction in dev

  tags = local.common_tags
}

# Database Module
module "database" {
  source = "./modules/database"

  project_name                = var.project_name
  environment                 = var.environment
  vpc_id                      = module.networking.vpc_id
  database_subnet_ids         = module.networking.database_subnet_ids
  database_security_group_ids = [module.security.database_security_group_id]

  # Database configuration
  db_name                  = var.db_name
  db_username              = var.db_username
  db_instance_class        = var.db_instance_class
  db_allocated_storage     = 20
  db_max_allocated_storage = 100

  # Production settings
  multi_az                    = var.environment == "prod" ? true : false
  enable_deletion_protection  = var.enable_deletion_protection
  backup_retention_period     = var.backup_retention_period
  enable_performance_insights = var.enable_monitoring

  tags = local.common_tags

  depends_on = [module.networking, module.security]
}

# ElastiCache Redis Module
module "elasticache" {
  source = "./modules/elasticache"
  count  = var.enable_elasticache_redis ? 1 : 0

  # Basic Configuration
  project_name = var.project_name
  environment  = var.environment

  # Network Configuration
  vpc_id                 = module.networking.vpc_id
  database_subnet_ids    = module.networking.database_subnet_ids
  ecs_security_group_ids = [module.security.ecs_tasks_security_group_id]

  # Redis Configuration
  redis_node_type          = var.redis_node_type
  redis_automatic_failover = var.redis_automatic_failover
  redis_multi_az           = var.redis_multi_az
  redis_num_cache_nodes    = var.redis_num_cache_nodes
  redis_auth_token         = var.redis_auth_token

  # Monitoring Configuration
  log_retention_days = var.log_retention_days
  alarm_actions      = []

  tags = local.common_tags

  depends_on = [module.networking, module.security]
}

# Load Balancer Module
module "load_balancer" {
  source = "./modules/load-balancer"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.networking.vpc_id
  public_subnet_ids      = module.networking.public_subnet_ids
  alb_security_group_ids = [module.security.alb_security_group_id]

  # DNS and SSL
  domain_name            = var.domain_name
  create_route53_zone    = var.create_route53_zone
  route53_zone_id        = var.existing_route53_zone_id
  create_acm_certificate = true

  # Target group configuration
  target_group_port = var.ctfd_container_port
  health_check_path = "/healthcheck"

  # Production settings
  enable_deletion_protection = var.enable_deletion_protection
  ssl_policy                 = "ELBSecurityPolicy-TLS-1-2-2017-01"
  redirect_http_to_https     = true

  tags = local.common_tags

  depends_on = [module.networking, module.security]
}

# ECS Module
module "ecs" {
  source = "./modules/ecs"

  project_name                = var.project_name
  environment                 = var.environment
  aws_region                  = var.aws_region
  vpc_id                      = module.networking.vpc_id
  private_subnet_ids          = module.networking.private_subnet_ids
  ecs_security_group_ids      = [module.security.ecs_tasks_security_group_id]
  alb_target_group_arn        = module.load_balancer.target_group_arn
  ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.security.ecs_task_role_arn

  # Container configuration
  container_image  = var.ctfd_container_image
  container_port   = var.ctfd_container_port
  container_cpu    = var.ecs_cpu
  container_memory = var.ecs_memory

  # Service configuration
  desired_count = var.ecs_desired_count
  max_capacity  = var.ecs_max_capacity
  min_capacity  = var.ecs_min_capacity

  # Database integration
  database_secret_arn = module.database.secrets_manager_secret_arn
  database_name       = var.db_name

  # S3 integration
  enable_s3_uploads = true
  s3_bucket_name    = module.storage.s3_bucket_name

  # Redis integration
  enable_redis = var.enable_elasticache_redis
  redis_url    = var.enable_elasticache_redis ? module.elasticache[0].redis_url : ""

  # Logging
  log_retention_days = var.log_retention_days

  tags = local.common_tags

  depends_on = [module.networking, module.security, module.database, module.load_balancer, module.storage]
}

# Monitoring Module
module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region

  # Resource references for monitoring
  load_balancer_arn_suffix  = module.load_balancer.load_balancer_arn_suffix
  target_group_arn_suffix   = module.load_balancer.target_group_arn_suffix
  ecs_cluster_name          = module.ecs.ecs_cluster_name
  ecs_service_name          = module.ecs.ecs_service_name
  db_instance_id            = module.database.db_instance_id
  cloudwatch_log_group_name = module.ecs.cloudwatch_log_group_name

  # Notification configuration
  create_sns_topic       = true
  notification_endpoints = var.notification_email_addresses

  # Dashboard and insights
  create_dashboard    = var.enable_monitoring
  enable_log_insights = var.enable_monitoring
  log_retention_days  = var.log_retention_days

  # Optional features
  enable_billing_alerts   = var.enable_billing_alerts
  billing_alert_threshold = var.billing_alert_threshold

  tags = local.common_tags

  depends_on = [module.ecs, module.load_balancer, module.database]
}

# Local values for common tags
locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    Repository  = "ctfd-ecs-fargate"
  }
}