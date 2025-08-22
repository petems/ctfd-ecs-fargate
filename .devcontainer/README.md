# Development Container Setup

This directory contains the configuration for a development container that provides a consistent Linux environment for developing the CTFd ECS Fargate Terraform project.

## What's Included

- **Ubuntu Linux** base environment
- **Terraform** (latest version)
- **Docker** and Docker-in-Docker support
- **AWS CLI v2** for AWS interactions
- **Additional tools**: curl, wget, unzip, jq, tree, htop
- **Terraform-docs** for documentation generation
- **VS Code extensions** for Terraform development

## Pre-installed VS Code Extensions

- HashiCorp Terraform
- HashiCorp HCL
- JSON support
- YAML support
- Docker
- Remote Containers
- Claude Code (AI assistant)

## Terraform Aliases

The container includes convenient aliases for common Terraform commands:

- `tf` - terraform
- `tfi` - terraform init
- `tfp` - terraform plan
- `tfa` - terraform apply
- `tfd` - terraform destroy
- `tfv` - terraform validate
- `tff` - terraform fmt

## Getting Started

1. **Prerequisites**: 
   - Install Docker Desktop
   - Install VS Code with the "Dev Containers" extension

2. **Open in Dev Container**:
   - Open this project in VS Code
   - When prompted, click "Reopen in Container" or use `Ctrl+Shift+P` and select "Dev Containers: Reopen in Container"

3. **First Run**:
   - The container will build automatically
   - Terraform and Docker versions will be displayed after setup
   - You can start working with Terraform immediately

## AWS Configuration

To work with AWS resources, you'll need to configure AWS credentials:

```bash
aws configure
```

Or set environment variables:
```bash
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_DEFAULT_REGION=your_region
```

## Terraform Workflow

1. **Initialize**: `tfi` or `terraform init`
2. **Plan**: `tfp` or `terraform plan`
3. **Apply**: `tfa` or `terraform apply`
4. **Destroy**: `tfd` or `terraform destroy`

## Persistence

- Your workspace files are mounted into the container
- Terraform state and lock files are preserved
- `.terraform` directory is cached for better performance

## Troubleshooting

- If the container fails to build, ensure Docker Desktop is running
- For AWS issues, verify your credentials are properly configured
- Check the VS Code Dev Containers extension is installed and up to date
