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

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_database"></a> [database](#module\_database) | ./modules/database | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ./modules/ecs | n/a |
| <a name="module_elasticache"></a> [elasticache](#module\_elasticache) | ./modules/elasticache | n/a |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ./modules/load-balancer | n/a |
| <a name="module_monitoring"></a> [monitoring](#module\_monitoring) | ./modules/monitoring | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |
| <a name="module_security"></a> [security](#module\_security) | ./modules/security | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones | `list(string)` | <pre>[<br/>  "us-west-2a",<br/>  "us-west-2b",<br/>  "us-west-2c"<br/>]</pre> | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-west-2"` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | RDS backup retention period in days | `number` | `7` | no |
| <a name="input_billing_alert_threshold"></a> [billing\_alert\_threshold](#input\_billing\_alert\_threshold) | Billing alert threshold in USD | `number` | `100` | no |
| <a name="input_create_ecr_repository"></a> [create\_ecr\_repository](#input\_create\_ecr\_repository) | Create ECR repository for custom CTFd images | `bool` | `true` | no |
| <a name="input_create_route53_zone"></a> [create\_route53\_zone](#input\_create\_route53\_zone) | Create new Route53 hosted zone | `bool` | `true` | no |
| <a name="input_ctfd_container_image"></a> [ctfd\_container\_image](#input\_ctfd\_container\_image) | CTFd container image | `string` | `"ctfd/ctfd:latest"` | no |
| <a name="input_ctfd_container_port"></a> [ctfd\_container\_port](#input\_ctfd\_container\_port) | CTFd container port | `number` | `8000` | no |
| <a name="input_database_subnet_cidrs"></a> [database\_subnet\_cidrs](#input\_database\_subnet\_cidrs) | CIDR blocks for database subnets | `list(string)` | <pre>[<br/>  "10.0.21.0/24",<br/>  "10.0.22.0/24",<br/>  "10.0.23.0/24"<br/>]</pre> | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | RDS instance class | `string` | `"db.t3.micro"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database name | `string` | `"ctfd"` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Database username | `string` | `"ctfduser"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name for the CTFd application | `string` | n/a | yes |
| <a name="input_ecs_cpu"></a> [ecs\_cpu](#input\_ecs\_cpu) | CPU units for ECS task | `number` | `256` | no |
| <a name="input_ecs_desired_count"></a> [ecs\_desired\_count](#input\_ecs\_desired\_count) | Desired number of ECS tasks | `number` | `1` | no |
| <a name="input_ecs_max_capacity"></a> [ecs\_max\_capacity](#input\_ecs\_max\_capacity) | Maximum number of ECS tasks | `number` | `10` | no |
| <a name="input_ecs_memory"></a> [ecs\_memory](#input\_ecs\_memory) | Memory for ECS task | `number` | `512` | no |
| <a name="input_ecs_min_capacity"></a> [ecs\_min\_capacity](#input\_ecs\_min\_capacity) | Minimum number of ECS tasks | `number` | `1` | no |
| <a name="input_enable_billing_alerts"></a> [enable\_billing\_alerts](#input\_enable\_billing\_alerts) | Enable billing alerts | `bool` | `false` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Enable deletion protection for RDS | `bool` | `true` | no |
| <a name="input_enable_elasticache_redis"></a> [enable\_elasticache\_redis](#input\_enable\_elasticache\_redis) | Enable ElastiCache Redis cluster | `bool` | `true` | no |
| <a name="input_enable_monitoring"></a> [enable\_monitoring](#input\_enable\_monitoring) | Enable enhanced monitoring | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_existing_database_subnet_ids"></a> [existing\_database\_subnet\_ids](#input\_existing\_database\_subnet\_ids) | IDs of existing database subnets | `list(string)` | `[]` | no |
| <a name="input_existing_private_subnet_ids"></a> [existing\_private\_subnet\_ids](#input\_existing\_private\_subnet\_ids) | IDs of existing private subnets | `list(string)` | `[]` | no |
| <a name="input_existing_public_subnet_ids"></a> [existing\_public\_subnet\_ids](#input\_existing\_public\_subnet\_ids) | IDs of existing public subnets | `list(string)` | `[]` | no |
| <a name="input_existing_route53_zone_id"></a> [existing\_route53\_zone\_id](#input\_existing\_route53\_zone\_id) | ID of existing Route53 zone (required if create\_route53\_zone = false) | `string` | `""` | no |
| <a name="input_existing_vpc_id"></a> [existing\_vpc\_id](#input\_existing\_vpc\_id) | ID of existing VPC to use (if provided, skips VPC creation) | `string` | `""` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention in days | `number` | `7` | no |
| <a name="input_notification_email_addresses"></a> [notification\_email\_addresses](#input\_notification\_email\_addresses) | List of email addresses for CloudWatch alarms | `list(string)` | `[]` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner/Team responsible for the infrastructure | `string` | `"devops"` | no |
| <a name="input_private_subnet_cidrs"></a> [private\_subnet\_cidrs](#input\_private\_subnet\_cidrs) | CIDR blocks for private subnets | `list(string)` | <pre>[<br/>  "10.0.11.0/24",<br/>  "10.0.12.0/24",<br/>  "10.0.13.0/24"<br/>]</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"ctfd"` | no |
| <a name="input_public_subnet_cidrs"></a> [public\_subnet\_cidrs](#input\_public\_subnet\_cidrs) | CIDR blocks for public subnets | `list(string)` | <pre>[<br/>  "10.0.1.0/24",<br/>  "10.0.2.0/24",<br/>  "10.0.3.0/24"<br/>]</pre> | no |
| <a name="input_redis_auth_token"></a> [redis\_auth\_token](#input\_redis\_auth\_token) | Auth token for Redis cluster (optional) | `string` | `""` | no |
| <a name="input_redis_automatic_failover"></a> [redis\_automatic\_failover](#input\_redis\_automatic\_failover) | Enable automatic failover for Redis cluster | `bool` | `true` | no |
| <a name="input_redis_multi_az"></a> [redis\_multi\_az](#input\_redis\_multi\_az) | Enable Multi-AZ for Redis cluster | `bool` | `true` | no |
| <a name="input_redis_node_type"></a> [redis\_node\_type](#input\_redis\_node\_type) | ElastiCache Redis node type | `string` | `"cache.t4.micro"` | no |
| <a name="input_redis_num_cache_nodes"></a> [redis\_num\_cache\_nodes](#input\_redis\_num\_cache\_nodes) | Number of cache nodes in Redis cluster | `number` | `2` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_certificate_arn"></a> [acm\_certificate\_arn](#output\_acm\_certificate\_arn) | ARN of the ACM SSL certificate |
| <a name="output_application_domain"></a> [application\_domain](#output\_application\_domain) | Domain name for the CTFd application |
| <a name="output_application_url"></a> [application\_url](#output\_application\_url) | URL to access the CTFd application |
| <a name="output_cloudwatch_dashboard_url"></a> [cloudwatch\_dashboard\_url](#output\_cloudwatch\_dashboard\_url) | URL to the CloudWatch dashboard |
| <a name="output_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#output\_cloudwatch\_log\_group) | CloudWatch log group for the application |
| <a name="output_container_image"></a> [container\_image](#output\_container\_image) | Container image being used |
| <a name="output_database_endpoint"></a> [database\_endpoint](#output\_database\_endpoint) | RDS database endpoint |
| <a name="output_database_secret_arn"></a> [database\_secret\_arn](#output\_database\_secret\_arn) | ARN of the database credentials secret in Secrets Manager |
| <a name="output_deployment_region"></a> [deployment\_region](#output\_deployment\_region) | AWS region where resources are deployed |
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | URL of the ECR repository |
| <a name="output_ecs_cluster_arn"></a> [ecs\_cluster\_arn](#output\_ecs\_cluster\_arn) | ARN of the ECS cluster |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | Name of the ECS cluster |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | Name of the ECS service |
| <a name="output_environment"></a> [environment](#output\_environment) | Environment name |
| <a name="output_load_balancer_arn"></a> [load\_balancer\_arn](#output\_load\_balancer\_arn) | ARN of the Application Load Balancer |
| <a name="output_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#output\_load\_balancer\_dns\_name) | DNS name of the Application Load Balancer |
| <a name="output_load_balancer_zone_id"></a> [load\_balancer\_zone\_id](#output\_load\_balancer\_zone\_id) | Zone ID of the Application Load Balancer |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | IDs of the private subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | IDs of the public subnets |
| <a name="output_redis_endpoint"></a> [redis\_endpoint](#output\_redis\_endpoint) | ElastiCache Redis primary endpoint |
| <a name="output_redis_port"></a> [redis\_port](#output\_redis\_port) | ElastiCache Redis port |
| <a name="output_redis_security_group_id"></a> [redis\_security\_group\_id](#output\_redis\_security\_group\_id) | ElastiCache Redis security group ID |
| <a name="output_redis_url"></a> [redis\_url](#output\_redis\_url) | ElastiCache Redis connection URL |
| <a name="output_route53_name_servers"></a> [route53\_name\_servers](#output\_route53\_name\_servers) | Name servers for the Route53 hosted zone (configure these in your domain registrar) |
| <a name="output_route53_zone_id"></a> [route53\_zone\_id](#output\_route53\_zone\_id) | ID of the Route53 hosted zone |
| <a name="output_s3_bucket_arn"></a> [s3\_bucket\_arn](#output\_s3\_bucket\_arn) | ARN of the S3 bucket for file uploads |
| <a name="output_s3_bucket_name"></a> [s3\_bucket\_name](#output\_s3\_bucket\_name) | Name of the S3 bucket for file uploads |
| <a name="output_security_groups"></a> [security\_groups](#output\_security\_groups) | Security group information |
| <a name="output_setup_instructions"></a> [setup\_instructions](#output\_setup\_instructions) | Quick setup instructions |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | ARN of the SNS topic for alerts |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
<!-- END_TF_DOCS -->