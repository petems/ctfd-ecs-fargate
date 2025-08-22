# Database Module

This module creates an RDS MySQL database instance for CTFd with comprehensive security, monitoring, and backup configurations.

## Features

- **RDS MySQL 8.0** with encryption at rest
- **Secrets Manager** integration for credential management
- **Enhanced monitoring** and CloudWatch alarms
- **Performance Insights** for query analysis
- **Automated backups** with point-in-time recovery
- **Custom parameter group** optimized for CTFd workloads
- **Multi-AZ deployment** support for high availability

## Architecture

```
ECS Tasks -> Database Security Group -> RDS MySQL
                                           |
                                    Secrets Manager
                                           |
                                    CloudWatch Monitoring
```

## Usage

```hcl
module "database" {
  source = "./modules/database"

  project_name                = "ctfd"
  environment                = "dev"
  vpc_id                     = module.networking.vpc_id
  database_subnet_ids        = module.networking.database_subnet_ids
  database_security_group_ids = [module.security.database_security_group_id]

  # Database Configuration
  db_instance_class          = "db.t3.micro"
  db_allocated_storage       = 20
  db_max_allocated_storage   = 100
  
  # Production Settings
  multi_az                   = false  # Set to true for production
  enable_deletion_protection = false  # Set to true for production
  backup_retention_period    = 7

  tags = {
    Owner = "devops"
  }
}
```

## Security Features

- **Encryption at rest** using AWS KMS
- **Network isolation** in private subnets
- **Secrets Manager** for credential rotation
- **Security group** restrictions to ECS tasks only
- **CloudWatch logging** for audit trails

## Monitoring & Alerting

- **CPU Utilization** alarm (>80%)
- **Database Connections** alarm (>180 connections)
- **Free Storage Space** alarm (<2GB)
- **Enhanced Monitoring** with 60-second granularity
- **Performance Insights** for query performance analysis

## Backup & Recovery

- **Automated backups** with configurable retention
- **Point-in-time recovery** up to retention period
- **Final snapshot** on deletion (configurable)
- **Cross-region backup** support

## Cost Optimization

- **Storage auto-scaling** to avoid over-provisioning
- **gp2 storage type** for cost-effective performance
- **Right-sizing** based on actual workload requirements

## Production Considerations

- Enable **Multi-AZ** deployment for high availability
- Set **deletion protection** to true
- Increase **backup retention** period
- Configure **maintenance window** during low-traffic periods
- Enable **automated minor version upgrades**