# Existing Resources CTFd ECS Fargate Example

This example demonstrates deploying CTFd using ECS Fargate with existing AWS resources (BYO - Bring Your Own).

## Prerequisites

Before running this example, ensure you have:

1. **Existing VPC** with the tag `Name = "existing-vpc"`
2. **Existing subnets** with appropriate tags:
   - Public subnets: `Type = "Public"`
   - Private subnets: `Type = "Private"`
   - Database subnets: `Type = "Database"`
3. **Existing Route53 hosted zone** for `example.com`
4. **Proper network connectivity** (Internet Gateway, NAT Gateway, etc.)

## Features

- Uses existing VPC and subnets
- Uses existing Route53 hosted zone
- Creates only application-specific resources:
  - Application Load Balancer
  - ECS Fargate cluster
  - RDS PostgreSQL database
  - S3 bucket for file uploads
  - Security groups
  - CloudWatch monitoring

## Usage

1. **Update the data sources** to match your existing resources:
   ```hcl
   data "aws_vpc" "existing" {
     tags = {
       Name = "your-vpc-name"  # Update this
     }
   }
   
   data "aws_route53_zone" "existing" {
     name = "yourdomain.com"  # Update this
   }
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Review the plan**:
   ```bash
   terraform plan
   ```

4. **Apply the configuration**:
   ```bash
   terraform apply
   ```

## Configuration

This example uses production-ready settings:

- **Environment**: Production
- **ECS**: 1024 CPU units, 2048 MB memory
- **Database**: db.t3.small
- **Auto-scaling**: 2-10 tasks
- **Monitoring**: Enhanced monitoring with billing alerts at $200
- **Security**: Deletion protection enabled
- **Backup**: 30-day retention

## Network Requirements

Your existing VPC must have:

- **Public subnets** with route to Internet Gateway
- **Private subnets** with route to NAT Gateway
- **Database subnets** (can be same as private subnets)
- **Security groups** allowing necessary traffic

## Cleanup

To destroy only the application resources (preserving existing infrastructure):
```bash
terraform destroy
```

## Notes

- This example is designed for production environments
- Ensure your existing VPC has proper network connectivity
- The module will create security groups that reference your existing VPC
- Consider using separate database subnets for better security isolation
