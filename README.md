# CTFd ECS Fargate Infrastructure

A complete Terraform module for deploying CTFd (Capture The Flag platform) on AWS using ECS Fargate with supporting infrastructure including RDS database, load balancing, SSL termination, and comprehensive monitoring.

## Architecture

```
Internet -> Route53 DNS -> ALB (SSL) -> ECS Fargate -> RDS MySQL
                |                          |
            ACM Certificate            S3 Storage
                |                          |
         CloudWatch Monitoring      CloudWatch Logs
```

## Features

- **🚀 Production-Ready**: Multi-AZ deployment with auto-scaling and health monitoring
- **🔒 Secure**: SSL termination, encrypted storage, network isolation, IAM least-privilege
- **📊 Observable**: CloudWatch dashboards, log aggregation, performance monitoring
- **💰 Cost-Optimized**: Configurable instance sizes, storage lifecycle policies
- **🔧 Modular**: Reusable components with flexible configuration
- **📱 Scalable**: Auto-scaling based on CPU/memory utilization

## Quick Start

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Domain name (for SSL certificate)

### Basic Usage

```hcl
module "ctfd_infrastructure" {
  source = "github.com/your-org/ctfd-ecs-fargate"

  # Basic Configuration
  project_name = "my-ctf"
  environment  = "prod"
  aws_region   = "us-west-2"
  domain_name  = "ctf.example.com"

  # Database Configuration
  db_instance_class = "db.t3.small"
  
  # Container Configuration
  ecs_cpu          = 512
  ecs_memory       = 1024
  ecs_desired_count = 2

  # Notification Configuration
  notification_email_addresses = ["admin@example.com"]

  tags = {
    Owner = "security-team"
  }
}
```

### Deployment Steps

1. **Configure your variables** in a `terraform.tfvars` file:
```hcl
project_name = "my-ctf"
environment  = "prod"
aws_region   = "us-west-2"
domain_name  = "ctf.example.com"
db_instance_class = "db.t3.small"
notification_email_addresses = ["admin@example.com"]
```

2. **Initialize and apply**:
```bash
terraform init
terraform plan
terraform apply
```

3. **Configure DNS** (if using external registrar):
   - Update your domain's name servers to the ones shown in the Terraform output

4. **Access your CTFd instance**:
   - Navigate to `https://your-domain.com`
   - Complete the CTFd setup wizard

## Configuration

### Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment name (dev, staging, prod) | `string` | n/a | yes |
| aws_region | AWS region | `string` | `"us-west-2"` | no |
| domain_name | Domain name for the application | `string` | n/a | yes |
| vpc_cidr | CIDR block for VPC | `string` | `"10.0.0.0/16"` | no |
| availability_zones | Availability zones | `list(string)` | `["us-west-2a", "us-west-2b", "us-west-2c"]` | no |
| db_instance_class | RDS instance class | `string` | `"db.t3.micro"` | no |
| db_name | Database name | `string` | `"ctfd"` | no |
| db_username | Database username | `string` | `"ctfduser"` | no |
| ecs_cpu | CPU units for ECS task | `number` | `256` | no |
| ecs_memory | Memory for ECS task | `number` | `512` | no |
| ecs_desired_count | Desired number of ECS tasks | `number` | `1` | no |
| ecs_max_capacity | Maximum number of ECS tasks | `number` | `10` | no |
| ctfd_container_image | CTFd container image | `string` | `"ctfd/ctfd:latest"` | no |
| enable_deletion_protection | Enable deletion protection | `bool` | `true` | no |
| backup_retention_period | RDS backup retention (days) | `number` | `7` | no |
| notification_email_addresses | Email addresses for alerts | `list(string)` | `[]` | no |
| enable_monitoring | Enable monitoring dashboard | `bool` | `true` | no |
| log_retention_days | CloudWatch log retention | `number` | `7` | no |

### Outputs

| Name | Description |
|------|-------------|
| application_url | URL to access the CTFd application |
| load_balancer_dns_name | DNS name of the load balancer |
| route53_name_servers | Name servers for Route53 zone |
| database_endpoint | RDS database endpoint |
| ecs_cluster_name | Name of the ECS cluster |
| s3_bucket_name | Name of the S3 bucket |
| cloudwatch_dashboard_url | URL to CloudWatch dashboard |

## Module Architecture

### Components

- **`modules/networking/`**: VPC, subnets, gateways, and routing
- **`modules/security/`**: Security groups, IAM roles, and policies
- **`modules/database/`**: RDS MySQL with backups and monitoring
- **`modules/storage/`**: S3 bucket and ECR repository
- **`modules/ecs/`**: ECS Fargate cluster, service, and tasks
- **`modules/load-balancer/`**: ALB, target groups, and SSL termination
- **`modules/monitoring/`**: CloudWatch dashboards, alarms, and SNS

### Security Features

- **Network Isolation**: Private subnets for application and database
- **Encryption**: SSL/TLS in transit, AES256 at rest
- **Access Control**: IAM roles with least-privilege permissions
- **Secret Management**: AWS Secrets Manager for credentials
- **Monitoring**: Comprehensive logging and alerting

### Cost Considerations

- **Development**: Use smaller instance sizes and single NAT gateway
- **Production**: Enable Multi-AZ, larger instances, enhanced monitoring
- **Storage**: Lifecycle policies automatically transition to cheaper storage

## Advanced Configuration

### Custom Container Images

Build and push custom CTFd images to the included ECR repository:

```bash
# Get ECR login
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-west-2.amazonaws.com

# Build and push
docker build -t my-ctfd .
docker tag my-ctfd:latest <account-id>.dkr.ecr.us-west-2.amazonaws.com/<repo-name>:latest
docker push <account-id>.dkr.ecr.us-west-2.amazonaws.com/<repo-name>:latest
```

### External Notifications

Configure external notification endpoints (Slack, webhooks, etc.):

```hcl
module "ctfd_infrastructure" {
  # ... other configuration

  # In the monitoring module call
  external_notification_endpoints = [
    {
      protocol = "https"
      endpoint = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
    },
    {
      protocol = "lambda"
      endpoint = "arn:aws:lambda:region:account:function:notification-handler"
    }
  ]
}
```

### Multi-Environment Setup

Use Terraform workspaces or separate configurations:

```bash
# Development
terraform workspace new dev
terraform apply -var="environment=dev" -var="db_instance_class=db.t3.micro"

# Production  
terraform workspace new prod
terraform apply -var="environment=prod" -var="db_instance_class=db.t3.small"
```

## Monitoring & Operations

### CloudWatch Dashboard

Access the automatically created dashboard to monitor:
- Application Load Balancer metrics
- ECS service performance
- RDS database metrics
- Application logs

### Log Analysis

Use CloudWatch Log Insights with pre-configured queries:
- Error logs detection
- Slow request analysis
- Request volume tracking

### Alerting

Configure email notifications for:
- High CPU/memory utilization
- Database connection issues
- Load balancer health problems
- Application errors

## Troubleshooting

### Common Issues

1. **SSL Certificate Validation Fails**
   ```bash
   # Check certificate status
   aws acm describe-certificate --certificate-arn <arn>
   
   # Verify DNS delegation
   dig NS your-domain.com
   ```

2. **ECS Tasks Not Starting**
   ```bash
   # Check ECS service events
   aws ecs describe-services --cluster <cluster> --services <service>
   
   # View container logs
   aws logs get-log-events --log-group-name /ecs/ctfd-prod
   ```

3. **Database Connection Issues**
   ```bash
   # Test database connectivity
   aws rds describe-db-instances --db-instance-identifier <id>
   
   # Check security groups
   aws ec2 describe-security-groups --group-ids <sg-id>
   ```

### Health Checks

- **Application**: `https://your-domain.com/healthcheck`
- **Load Balancer**: Check target group health in AWS Console
- **Database**: Monitor RDS metrics in CloudWatch

## Contributing

This module follows standard Terraform conventions:

1. **Variables**: Defined in `variables.tf` with descriptions and types
2. **Outputs**: Exposed in `outputs.tf` with descriptions
3. **Documentation**: README files in each module
4. **Examples**: Provided in usage documentation

## Security Best Practices

- **Regular Updates**: Keep container images and dependencies updated
- **Access Control**: Use IAM roles instead of access keys
- **Network Security**: Leverage security groups and private subnets
- **Monitoring**: Enable CloudTrail and GuardDuty for additional security
- **Secrets**: Never commit secrets to version control

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

- **Issues**: Report bugs and feature requests via GitHub Issues
- **Documentation**: Check module README files for detailed configuration
- **AWS Support**: Use AWS Support for infrastructure-related issues