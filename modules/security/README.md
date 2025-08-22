# Security Module

This module creates security groups and IAM roles for the CTFd ECS Fargate infrastructure, implementing security best practices with least-privilege access.

## Architecture

```
Internet -> ALB (Security Group) -> ECS Tasks (Security Group) -> RDS (Security Group)
                                           |
                                    IAM Roles (Task + Execution)
```

## Security Groups

- **ALB Security Group**: HTTP/HTTPS inbound from internet, all outbound
- **ECS Tasks Security Group**: Application port inbound from ALB only, all outbound
- **Database Security Group**: Database port inbound from ECS tasks only
- **VPC Endpoints Security Group**: HTTPS inbound from VPC CIDR

## IAM Roles

- **ECS Task Execution Role**: For pulling images, logging, and secrets access
- **ECS Task Role**: For application runtime permissions (S3, CloudWatch, Secrets Manager)

## Usage

```hcl
module "security" {
  source = "./modules/security"

  project_name    = "ctfd"
  environment     = "dev"
  vpc_id          = module.networking.vpc_id
  vpc_cidr_block  = module.networking.vpc_cidr_block
  s3_bucket_arn   = module.storage.bucket_arn

  tags = {
    Owner = "devops"
  }
}
```

## Security Features

- **Network Segmentation**: Security groups enforce traffic flow restrictions
- **Least Privilege**: IAM roles have minimal required permissions
- **Secrets Management**: Secure access to database credentials via Secrets Manager
- **Logging Access**: CloudWatch logs permissions for monitoring
- **S3 Access Control**: Scoped permissions for file storage

## Compliance

- Follows AWS Well-Architected Security Pillar
- Implements defense-in-depth strategy
- Supports audit and compliance requirements