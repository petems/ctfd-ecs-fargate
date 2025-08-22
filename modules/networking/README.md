# Networking Module

This module creates the core networking infrastructure for the CTFd application, including:

- VPC with DNS support
- Public, private, and database subnets across multiple AZs
- Internet Gateway for public internet access
- NAT Gateways for private subnet internet access
- Route tables and associations
- VPC Flow Logs for monitoring

## Architecture

```
Internet Gateway
        |
    Public Subnets (ALB)
        |
    NAT Gateway
        |
    Private Subnets (ECS)
        |
    Database Subnets (RDS)
```

## Usage

```hcl
module "networking" {
  source = "./modules/networking"

  project_name            = "ctfd"
  environment            = "dev"
  vpc_cidr               = "10.0.0.0/16"
  availability_zones     = ["us-west-2a", "us-west-2b", "us-west-2c"]
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  database_subnet_cidrs  = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

  tags = {
    Owner = "devops"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| project_name | Name of the project | `string` | n/a | yes |
| environment | Environment name | `string` | n/a | yes |
| vpc_cidr | CIDR block for VPC | `string` | n/a | yes |
| availability_zones | Availability zones | `list(string)` | n/a | yes |
| public_subnet_cidrs | CIDR blocks for public subnets | `list(string)` | n/a | yes |
| private_subnet_cidrs | CIDR blocks for private subnets | `list(string)` | n/a | yes |
| database_subnet_cidrs | CIDR blocks for database subnets | `list(string)` | n/a | yes |
| enable_nat_gateway | Enable NAT Gateway | `bool` | `true` | no |
| single_nat_gateway | Use a single NAT Gateway | `bool` | `false` | no |
| enable_dns_hostnames | Enable DNS hostnames in VPC | `bool` | `true` | no |
| enable_dns_support | Enable DNS support in VPC | `bool` | `true` | no |
| tags | Additional tags for resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | ID of the VPC |
| vpc_cidr_block | CIDR block of the VPC |
| internet_gateway_id | ID of the Internet Gateway |
| public_subnet_ids | IDs of the public subnets |
| private_subnet_ids | IDs of the private subnets |
| database_subnet_ids | IDs of the database subnets |
| nat_gateway_ids | IDs of the NAT Gateways |
| public_route_table_id | ID of the public route table |
| private_route_table_ids | IDs of the private route tables |
| database_route_table_id | ID of the database route table |
| availability_zones | Availability zones used |

## Cost Optimization

- Set `single_nat_gateway = true` for development environments to reduce costs
- NAT Gateway charges apply per hour and per GB processed
- VPC Flow Logs generate CloudWatch charges based on log volume

## Security Features

- VPC Flow Logs enabled for network monitoring
- Database subnets isolated from internet access
- Private subnets route internet traffic through NAT Gateway