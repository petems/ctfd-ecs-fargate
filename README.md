# CTFd ECS Fargate Terraform Module

A comprehensive Terraform module for deploying CTFd (Capture The Flag framework) on AWS ECS Fargate with a complete infrastructure stack.

## Features

- **ECS Fargate**: Containerized CTFd application with auto-scaling
- **Load Balancer**: Application Load Balancer with SSL/TLS termination
- **Database**: RDS PostgreSQL with automated backups and monitoring
- **Caching**: ElastiCache Redis cluster for session management
- **Storage**: S3 bucket for file uploads and static assets
- **Networking**: VPC with public, private, and database subnets
- **Security**: IAM roles, security groups, and Secrets Manager
- **Monitoring**: CloudWatch dashboards, alarms, and logging
- **DNS**: Route53 hosted zone and SSL certificate management
- **Cost Optimization**: Development vs production configurations

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Route53 DNS   │    │   CloudFront    │    │   S3 Bucket     │
│                 │    │   (Optional)    │    │   (Static)      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   ALB + SSL     │
                    │   Certificate   │
                    └─────────────────┘
                                 │
                    ┌─────────────────┐
                    │   ECS Fargate   │
                    │   (CTFd App)    │
                    └─────────────────┘
                                 │
         ┌───────────────────────┼───────────────────────┐
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   RDS           │    │   ElastiCache   │    │   CloudWatch    │
│   PostgreSQL    │    │   Redis         │    │   Monitoring    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Quick Start

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- Domain name for your CTFd instance

### Basic Usage

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd ctfd-ecs-fargate
   ```

2. **Copy the example configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **Update the configuration**:
   ```hcl
   # Update these values in terraform.tfvars
   project_name = "my-ctfd"
   environment  = "dev"
   domain_name  = "ctfd.yourdomain.com"
   ```

4. **Initialize and apply**:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

### Example Configurations

#### Development Environment
```hcl
module "ctfd" {
  source = "./modules/ctfd-ecs-fargate"

  project_name = "ctfd-dev"
  environment  = "dev"
  domain_name  = "ctfd-dev.example.com"
  
  # Cost-optimized settings
  ecs_cpu         = 256
  ecs_memory      = 512
  db_instance_class = "db.t3.micro"
  
  # Development features
  enable_deletion_protection = false
  backup_retention_period    = 1
  log_retention_days        = 7
}
```

#### Production Environment
```hcl
module "ctfd" {
  source = "./modules/ctfd-ecs-fargate"

  project_name = "ctfd-prod"
  environment  = "prod"
  domain_name  = "ctfd.example.com"
  
  # Production settings
  ecs_cpu         = 1024
  ecs_memory      = 2048
  db_instance_class = "db.t3.medium"
  
  # Production features
  enable_deletion_protection = true
  backup_retention_period    = 30
  log_retention_days        = 90
  multi_az                  = true
}
```

## Module Structure

```
ctfd-ecs-fargate/
├── main.tf                 # Main module configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── versions.tf             # Terraform and provider versions
├── backend.tf              # Backend configuration
├── terraform.tfvars.example # Example variable values
├── README.md               # This file
├── LICENSE                 # License file
├── modules/                # Sub-modules
│   ├── networking/         # VPC, subnets, routing
│   ├── security/           # IAM roles, security groups
│   ├── storage/            # S3 bucket, ECR repository
│   ├── database/           # RDS PostgreSQL
│   ├── elasticache/        # Redis cluster
│   ├── load-balancer/      # ALB, SSL, Route53
│   ├── ecs/                # ECS cluster and service
│   └── monitoring/         # CloudWatch, alarms
└── examples/               # Usage examples
    ├── basic/              # Basic deployment
    └── existing-resources/ # Using existing resources
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | `"ctfd"` | yes |
| environment | Environment name | `string` | `"dev"` | yes |
| domain_name | Domain name for the CTFd application | `string` | n/a | yes |
| aws_region | AWS region | `string` | `"us-west-2"` | no |
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| availability_zones | Availability zones | `list(string)` | `["us-west-2a", "us-west-2b", "us-west-2c"]` | no |
| ecs_cpu | CPU units for ECS tasks | `number` | `256` | no |
| ecs_memory | Memory for ECS tasks (MB) | `number` | `512` | no |
| db_instance_class | RDS instance class | `string` | `"db.t3.micro"` | no |
| enable_elasticache_redis | Enable ElastiCache Redis | `bool` | `true` | no |
| enable_monitoring | Enable CloudWatch monitoring | `bool` | `true` | no |
| enable_deletion_protection | Enable RDS deletion protection | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| application_url | URL to access the CTFd application |
| load_balancer_dns_name | DNS name of the Application Load Balancer |
| database_endpoint | RDS database endpoint |
| redis_endpoint | ElastiCache Redis endpoint |
| ecs_cluster_name | Name of the ECS cluster |
| s3_bucket_name | Name of the S3 bucket |

## Security

This module implements security best practices:

- **Network Security**: Private subnets for application and database tiers
- **IAM Roles**: Least-privilege access with specific permissions
- **Secrets Management**: Database credentials stored in AWS Secrets Manager
- **SSL/TLS**: HTTPS with ACM certificates
- **Security Groups**: Restrictive firewall rules
- **Encryption**: Data encrypted at rest and in transit

## Monitoring

The module includes comprehensive monitoring:

- **CloudWatch Dashboards**: Application and infrastructure metrics
- **Alarms**: CPU, memory, and error rate monitoring
- **Logging**: Centralized logging with retention policies
- **Billing Alerts**: Cost monitoring and alerts
- **X-Ray Tracing**: Distributed tracing (optional)

## Cost Optimization

The module includes cost optimization features:

- **Development Mode**: Single AZ, smaller instances, shorter retention
- **Production Mode**: Multi-AZ, larger instances, longer retention
- **Auto Scaling**: Scale based on demand
- **Spot Instances**: Optional for non-critical workloads
- **Reserved Instances**: Support for RDS reserved instances

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Development Setup

#### Prerequisites
- Terraform >= 1.0
- AWS CLI configured
- Pre-commit hooks (optional but recommended)

#### Local Development
1. **Install pre-commit hooks** (recommended):
   ```bash
   pip install pre-commit
   pre-commit install
   ```

2. **Run validation locally**:
   ```bash
   terraform init
   terraform validate
   terraform fmt -check -recursive
   ```

3. **Run security scans locally**:
   ```bash
   # Install TFLint
   curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
   
   # Run TFLint
   tflint
   
   # Install Checkov
   pip install checkov
   
   # Run Checkov
   checkov -d .
   ```

### GitHub Actions

This repository includes comprehensive GitHub Actions workflows for:

- **Validation**: Automatic Terraform validation and formatting checks
- **Testing**: Module validation and syntax testing
- **Security**: Automated security scanning and compliance checks
- **Documentation**: Auto-generation of documentation
- **Cleanup**: Automatic cleanup of test artifacts

See [`.github/workflows/README.md`](.github/workflows/README.md) for detailed workflow documentation.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions:

1. Check the [examples](examples/) directory
2. Review the [documentation](docs/)
3. Open an issue on GitHub
4. Contact the maintainers

## Changelog

### v1.0.0
- Initial release
- Complete ECS Fargate deployment
- All core infrastructure components
- Monitoring and security features
