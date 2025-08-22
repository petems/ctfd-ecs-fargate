# Basic CTFd ECS Fargate Example

This example demonstrates a basic deployment of CTFd using ECS Fargate with all resources created from scratch.

## Features

- Complete VPC with public, private, and database subnets
- Application Load Balancer with SSL/TLS termination
- ECS Fargate cluster with auto-scaling
- RDS PostgreSQL database
- ElastiCache Redis cluster for caching
- S3 bucket for file uploads
- CloudWatch monitoring and logging
- Route53 DNS management
- ACM SSL certificate

## Usage

1. **Initialize Terraform**:
   ```bash
   terraform init
   ```

2. **Review the plan**:
   ```bash
   terraform plan
   ```

3. **Apply the configuration**:
   ```bash
   terraform apply
   ```

4. **Access CTFd**:
   - URL: `https://ctfd.example.com`
   - Default admin credentials will be available in the ECS task logs

## Configuration

This example uses the following key settings:

- **Environment**: Development (cost-optimized)
- **Region**: us-west-2
- **VPC CIDR**: 10.0.0.0/16
- **ECS**: 256 CPU units, 512 MB memory
- **Database**: db.t3.micro (suitable for development)
- **Redis**: cache.t4.micro with single node (development)
- **Monitoring**: Enabled with billing alerts at $50

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

## Notes

- This example is designed for development/testing
- Production deployments should use larger instance sizes
- Consider enabling deletion protection for production
- Update the domain name to match your DNS configuration
