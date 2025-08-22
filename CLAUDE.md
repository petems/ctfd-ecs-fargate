# CTFd ECS Fargate Infrastructure

This repository contains Terraform infrastructure code to deploy CTFd (Capture The Flag platform) on AWS using ECS Fargate.

## Project Overview

**Objective**: Deploy a scalable, secure CTFd application on AWS ECS Fargate with supporting infrastructure including RDS database, load balancing, SSL termination, and monitoring.

**Architecture**:
```
Internet -> Route53 DNS -> ALB (SSL) -> ECS Fargate -> RDS MySQL
                |                          |
            ACM Certificate            S3 Storage
                |                          |
         CloudWatch Monitoring      CloudWatch Logs
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
├── LICENSE                   # MIT License for Registry compliance
├── examples/
│   ├── basic/               # Basic deployment example
│   └── existing-resources/  # BYO resources example
├── modules/
│   ├── networking/           # VPC, subnets, gateways
│   ├── security/             # Security groups, IAM
│   ├── database/             # RDS configuration
│   ├── storage/              # S3, ECR
│   ├── ecs/                  # Fargate cluster & services
│   ├── load-balancer/        # ALB configuration
│   └── monitoring/           # CloudWatch, alarms
```

## ✅ Implementation Status - COMPLETED

### Phase 1: Foundation ✅
- ✅ Project setup with S3 + DynamoDB state management
- ✅ Provider versions and constraints configured
- ✅ Base variables and examples defined
- ✅ Complete module directory structure

### Phase 2: Security & Database ✅
- ✅ Security module with IAM roles and security groups
- ✅ Database module with RDS MySQL and Secrets Manager
- ✅ Comprehensive security best practices implemented

### Phase 3: Container Infrastructure ✅
- ✅ Storage module with S3 and ECR
- ✅ ECS module with Fargate cluster and auto-scaling
- ✅ Container insights and CloudWatch logging

### Phase 4: Load Balancing & DNS ✅
- ✅ Load balancer module with ALB and SSL termination
- ✅ Route53 DNS management with ACM certificates
- ✅ Support for existing DNS zones (BYO)

### Phase 5: Operations & Monitoring ✅
- ✅ Monitoring module with CloudWatch dashboards and alarms
- ✅ SNS notifications and billing alerts
- ✅ Comprehensive logging and alerting

## ✅ Key Features Implemented

### Enterprise-Ready Features
- **BYO (Bring Your Own) Resource Support**: Use existing VPC, subnets, and Route53 zones
- **Comprehensive Validation**: Input validation for all critical parameters
- **Security Best Practices**: IAM least-privilege, encrypted storage, network isolation
- **Production Monitoring**: CloudWatch dashboards, alarms, and SNS notifications
- **Cost Optimization**: Configurable instance sizes, storage lifecycle policies
- **Multi-Environment Support**: Development, staging, and production configurations

### Security Features
- **Network Isolation**: Private subnets for application and database
- **Encryption**: SSL/TLS in transit, AES256 at rest
- **Access Control**: IAM roles with least-privilege permissions
- **Secret Management**: AWS Secrets Manager for credentials
- **Monitoring**: Comprehensive logging and alerting
- **CORS Security**: Environment-based validation preventing wildcard origins in production

### Registry Compliance
- ✅ MIT LICENSE file
- ✅ Comprehensive examples directory
- ✅ Registry-compliant README with badges
- ✅ Proper documentation and usage examples
- ✅ Version constraints and provider requirements

## Configuration

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

### BYO Resource Support
```hcl
# Use existing VPC and subnets
existing_vpc_id = "vpc-12345678"
existing_public_subnet_ids = ["subnet-12345678", "subnet-87654321"]
existing_private_subnet_ids = ["subnet-abcdef12", "subnet-21fedcba"]
existing_database_subnet_ids = ["subnet-1234abcd", "subnet-dcba4321"]

# Use existing Route53 zone
create_route53_zone = false
existing_route53_zone_id = "Z1234567890ABC"
```

## Dependencies & Prerequisites

### Required Tools
- AWS CLI configured with administrative permissions
- Terraform >= 1.0
- Docker (for local CTFd image building/testing)

### AWS Resources
- Domain name registered and hosted in Route53 (or existing zone)
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
3. Create `terraform.tfvars` and customize for your deployment
4. Use `backend.tf` for remote state configuration
5. Initialize Terraform: `terraform init`

#### Option B: Local State (Development/Testing Only)
1. Configure AWS CLI: `aws configure`
2. Copy `backend-local.tf.example` to `backend.tf` for local state
3. Create `terraform.tfvars` and customize for your deployment
4. Initialize Terraform: `terraform init`

**Note**: Local state should only be used for development or testing. Production deployments should always use remote state with S3 and DynamoDB for state locking.

### Deployment Commands
```bash
# Plan deployment
terraform plan

# Apply infrastructure
terraform apply

# Destroy infrastructure (when needed)
terraform destroy
```

### Validation Steps
1. Verify ECS service is running and healthy
2. Check load balancer target health
3. Validate database connectivity from ECS tasks
4. Test DNS resolution and SSL certificate
5. Verify CTFd application accessibility
6. Test file upload functionality with S3

## ✅ Critical Success Metrics - ACHIEVED

- ✅ CTFd application accessible via HTTPS on custom domain
- ✅ Database connectivity and data persistence working
- ✅ File upload functionality operational with S3
- ✅ Auto-scaling policies responding to load changes
- ✅ SSL certificate valid and auto-renewing
- ✅ Monitoring and alerting fully operational
- ✅ All AWS security best practices implemented
- ✅ Infrastructure costs within expected parameters
- ✅ Deployment process documented and reproducible
- ✅ BYO resource support for enterprise integration
- ✅ Terraform Registry compliance achieved

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

### BYO Resource Issues
- Verify existing VPC has proper network connectivity
- Ensure existing subnets have correct route table associations
- Check that existing Route53 zone is properly configured

## Cost Optimization Notes

- Use Fargate Spot for development environments
- Configure appropriate RDS instance sizing
- Implement S3 Intelligent Tiering for uploaded files
- Set CloudWatch log retention policies
- Use ECR lifecycle policies to manage image storage costs
- Enable single NAT gateway for development environments

## Future Enhancements

- CI/CD pipeline integration with GitHub Actions
- Multi-environment deployment automation
- Enhanced monitoring with custom metrics
- Backup and disaster recovery automation
- Container image vulnerability scanning
- WAF integration for additional security
- Support for additional database engines (PostgreSQL, Aurora)

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

# Test BYO resource scenarios
cd examples/existing-resources
terraform plan

# Test basic deployment
cd examples/basic
terraform plan
```

## Registry Publication Checklist

### ✅ Pre-Publication Requirements
- [x] All critical and high-priority issues resolved
- [x] Comprehensive test scenarios supported
- [x] Registry requirements checklist completed
- [x] Security review approved
- [x] Documentation complete and accurate
- [x] Examples working and documented
- [x] LICENSE file present (MIT)
- [x] README updated with Registry format
- [x] Version badges and metadata added

### Post-Publication Tasks
- Monitor Registry download metrics
- Track and respond to community issues
- Maintain compatibility with provider updates
- Regular security reviews and updates
- Version management and release notes