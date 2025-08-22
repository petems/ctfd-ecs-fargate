# CTFd ECS Fargate Infrastructure

This repository contains Terraform infrastructure code to deploy CTFd (Capture The Flag platform) on AWS using ECS Fargate.

## Project Overview

**Objective**: Deploy a scalable, secure CTFd application on AWS ECS Fargate with supporting infrastructure including RDS database, load balancing, SSL termination, and monitoring.

**Architecture**:
```
Internet -> ALB -> ECS Fargate -> RDS MySQL
                    |
                    v
                 S3 Storage
```

## Repository Structure

```
ctfd-ecs-fargate/
├── backend.tf                 # Terraform state management (S3 or local)
├── backend-local.tf.example      # Local state configuration example
├── versions.tf               # Provider versions
├── variables.tf              # Input variables
├── main.tf                   # Root module configuration
├── outputs.tf                # Infrastructure outputs
├── terraform.tfvars.example  # Example variables
├── README.md                 # User-facing documentation
├── modules/
│   ├── networking/           # VPC, subnets, gateways
│   ├── security/             # Security groups, IAM
│   ├── database/             # RDS configuration
│   ├── storage/              # S3, ECR
│   ├── ecs/                  # Fargate cluster & services
│   ├── load-balancer/        # ALB configuration
│   └── monitoring/           # CloudWatch, alarms
└── environments/
    ├── dev.tfvars
    └── prod.tfvars
```

## Implementation Plan

### Phase 1: Foundation (Priority: Critical)

#### Task 1.1: Project Setup
- [ ] Create `backend.tf` with S3 + DynamoDB state management
- [ ] Create `backend-local.tf.example` for local state option
- [ ] Set up `versions.tf` with Terraform and AWS provider constraints
- [ ] Define base `variables.tf` and `terraform.tfvars.example`
- [ ] Create directory structure for modules

#### Task 1.2: Networking Module (`modules/networking/`)
- [ ] VPC with DNS hostnames enabled
- [ ] Public subnets (2-3 AZs) for load balancer
- [ ] Private subnets (2-3 AZs) for ECS and RDS
- [ ] Internet Gateway and NAT Gateways
- [ ] Route tables and associations
- [ ] Module variables, outputs, and documentation

### Phase 2: Security & Database (Priority: Critical)

#### Task 2.1: Security Module (`modules/security/`)
- [ ] Security group for ALB (HTTP/HTTPS inbound)
- [ ] Security group for ECS tasks (ALB access only)
- [ ] Security group for RDS (ECS access only)
- [ ] IAM role for ECS task execution
- [ ] IAM role for ECS tasks with S3/CloudWatch permissions
- [ ] IAM policies for required AWS services

#### Task 2.2: Database Module (`modules/database/`)
- [ ] RDS MySQL instance with encryption
- [ ] DB subnet group in private subnets
- [ ] Parameter group optimized for CTFd
- [ ] AWS Secrets Manager for database credentials
- [ ] Automated backups with 7-day retention
- [ ] Performance Insights configuration

### Phase 3: Container Infrastructure (Priority: High)

#### Task 3.1: Storage Module (`modules/storage/`)
- [ ] ECR repository for CTFd container images
- [ ] Lifecycle policy for ECR cost optimization
- [ ] S3 bucket for CTFd file uploads
- [ ] S3 bucket policy for ECS task access
- [ ] S3 versioning and encryption configuration

#### Task 3.2: ECS Module (`modules/ecs/`)
- [ ] ECS Fargate cluster with Container Insights
- [ ] Task definition with CTFd container specifications
- [ ] Environment variables configuration
- [ ] Secrets Manager integration
- [ ] ECS service with desired count
- [ ] Auto Scaling target and policies
- [ ] CloudWatch logging configuration

### Phase 4: Load Balancing & DNS (Priority: High)

#### Task 4.1: Load Balancer Module (`modules/load-balancer/`)
- [ ] Application Load Balancer in public subnets
- [ ] Target group with health checks
- [ ] Security group rules for web traffic
- [ ] Listener rules for HTTP/HTTPS
- [ ] SSL certificate integration

#### Task 4.2: DNS & SSL Configuration
- [ ] Route53 hosted zone setup
- [ ] ACM SSL certificate with DNS validation
- [ ] A record pointing to load balancer
- [ ] Certificate validation records

### Phase 5: Operations & Monitoring (Priority: Medium)

#### Task 5.1: Monitoring Module (`modules/monitoring/`)
- [ ] CloudWatch Log Groups for ECS containers
- [ ] CloudWatch Alarms for ECS service health
- [ ] CloudWatch Alarms for RDS metrics
- [ ] CloudWatch Alarms for ALB metrics
- [ ] SNS topics for alert notifications
- [ ] CloudWatch Dashboard for infrastructure overview

#### Task 5.2: Root Configuration
- [ ] `main.tf` calling all modules with proper dependencies
- [ ] `outputs.tf` exposing key infrastructure endpoints
- [ ] Environment-specific tfvars files
- [ ] Comprehensive `README.md` for users

## Key Configuration Requirements

### CTFd Environment Variables
- `DATABASE_URL`: RDS connection string from Secrets Manager
- `UPLOAD_PROVIDER`: "s3" for file storage
- `AWS_S3_BUCKET`: S3 bucket name for uploads
- `AWS_S3_REGION`: AWS region
- `MAIL_SERVER`: SMTP configuration for notifications

### Resource Tagging Strategy
```hcl
common_tags = {
  Project     = "ctfd-infrastructure"
  Environment = var.environment
  ManagedBy   = "terraform"
  Owner       = var.owner
}
```

### Security Best Practices
- All traffic encrypted in transit (HTTPS, RDS encryption)
- Private subnets for application and database tiers
- Least-privilege IAM roles and policies
- Security groups with minimal required access
- Secrets managed via AWS Secrets Manager

## Dependencies & Prerequisites

### Required Tools
- AWS CLI configured with administrative permissions
- Terraform >= 1.0
- Docker (for local CTFd image building/testing)

### AWS Resources
- Domain name registered and hosted in Route53
- AWS account with appropriate service limits
- Separate S3 bucket for Terraform state (not managed by this code)

### Required AWS Permissions
- EC2, VPC, and networking services
- ECS, Fargate, and container registry
- RDS database creation and management
- IAM role and policy creation
- Route53 DNS management
- ACM certificate management
- CloudWatch logging and monitoring

## Deployment Process

### Initial Setup

#### Option A: Remote State (Recommended for Production)
1. Configure AWS CLI: `aws configure`
2. Create Terraform state bucket manually (separate from application)
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and customize
4. Use `backend.tf` for remote state configuration
5. Initialize Terraform: `terraform init`

#### Option B: Local State (Development/Testing Only)
1. Configure AWS CLI: `aws configure`
2. Copy `backend-local.tf.example` to `backend.tf` for local state
3. Copy `terraform.tfvars.example` to `terraform.tfvars` and customize
4. Initialize Terraform: `terraform init`

**Note**: Local state should only be used for development or testing. Production deployments should always use remote state with S3 and DynamoDB for state locking.

### Deployment Commands
```bash
# Plan deployment
terraform plan -var-file=environments/dev.tfvars

# Apply infrastructure
terraform apply -var-file=environments/dev.tfvars

# Destroy infrastructure (when needed)
terraform destroy -var-file=environments/dev.tfvars
```

### Validation Steps
1. Verify ECS service is running and healthy
2. Check load balancer target health
3. Validate database connectivity from ECS tasks
4. Test DNS resolution and SSL certificate
5. Verify CTFd application accessibility
6. Test file upload functionality with S3

## Critical Success Metrics

- [ ] CTFd application accessible via HTTPS on custom domain
- [ ] Database connectivity and data persistence working
- [ ] File upload functionality operational with S3
- [ ] Auto-scaling policies responding to load changes
- [ ] SSL certificate valid and auto-renewing
- [ ] Monitoring and alerting fully operational
- [ ] All AWS security best practices implemented
- [ ] Infrastructure costs within expected parameters
- [ ] Deployment process documented and reproducible

## Troubleshooting Common Issues

### ECS Service Issues
- Check security group rules between ALB and ECS
- Verify ECS task has proper IAM permissions
- Review CloudWatch logs for container startup errors

### Database Connection Problems
- Validate security group rules between ECS and RDS
- Check Secrets Manager configuration
- Verify RDS instance is in correct subnet group

### Load Balancer Issues
- Confirm target group health checks are configured correctly
- Verify ALB is in public subnets with internet gateway access
- Check DNS and SSL certificate configuration

## Cost Optimization Notes

- Use Fargate Spot for development environments
- Configure appropriate RDS instance sizing
- Implement S3 Intelligent Tiering for uploaded files
- Set CloudWatch log retention policies
- Use ECR lifecycle policies to manage image storage costs

## Future Enhancements

- CI/CD pipeline integration with GitHub Actions
- Multi-environment deployment automation
- Enhanced monitoring with custom metrics
- Backup and disaster recovery automation
- Container image vulnerability scanning
- WAF integration for additional security

## Commands for Claude

When working on this project, use these common commands:

```bash
# Lint and validate Terraform code
terraform fmt -recursive
terraform validate

# Plan with specific environment
terraform plan -var-file=environments/dev.tfvars

# Check resource dependencies
terraform graph | dot -Tpng > infrastructure.png

# View current state
terraform show

# Import existing resources (if needed)
terraform import aws_vpc.main vpc-xxxxxxxxx

# Switch between local and remote state
# For local state: copy backend-local.tf.example to backend.tf
# For remote state: use the original backend.tf with S3 configuration
cp backend-local.tf.example backend.tf  # Use local state
# OR use backend.tf with S3 configuration for remote state

# Migrate from local to remote state
terraform init -migrate-state
```