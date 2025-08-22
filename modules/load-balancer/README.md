# Load Balancer Module

This module creates an Application Load Balancer (ALB) with SSL termination, Route53 DNS configuration, and comprehensive monitoring for the CTFd application.

## Architecture

```
Internet -> Route53 DNS -> ALB (HTTPS/HTTP) -> Target Group -> ECS Tasks
                |                                    |
            ACM Certificate                   Health Checks
```

## Features

### Application Load Balancer
- **Multi-AZ deployment** across public subnets
- **SSL termination** with ACM certificate
- **HTTP to HTTPS redirection** (configurable)
- **Health checks** with custom paths
- **IPv4 and IPv6 support**
- **Cross-zone load balancing**

### DNS & SSL
- **Route53 hosted zone** creation or existing zone usage
- **ACM SSL certificate** with DNS validation
- **Automatic certificate validation**
- **A and AAAA records** for IPv4/IPv6

### Security & Compliance
- **Security group integration** 
- **WAF v2 support** (optional)
- **SSL security policies** with modern TLS
- **Access logs** to S3 (optional)

### Monitoring
- **CloudWatch alarms** for response time, healthy hosts, and HTTP errors
- **Target group health monitoring**
- **Load balancer metrics**

## Usage

```hcl
module "load_balancer" {
  source = "./modules/load-balancer"

  project_name           = "ctfd"
  environment           = "dev"
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_ids = [module.security.alb_security_group_id]

  # DNS Configuration
  domain_name            = "ctf.example.com"
  create_route53_zone    = true
  create_acm_certificate = true

  # ALB Configuration
  enable_deletion_protection = false  # Set to true for production
  idle_timeout              = 60
  enable_http2              = true

  # Target Group Configuration
  target_group_port     = 8000
  health_check_path     = "/healthcheck"
  health_check_interval = 30

  # Listener Configuration
  enable_https_listener    = true
  redirect_http_to_https   = true
  ssl_policy              = "ELBSecurityPolicy-TLS-1-2-2017-01"

  # Optional Features
  enable_access_logs = false
  enable_waf         = false

  tags = {
    Owner = "devops"
  }
}
```

## Health Check Configuration

The module configures health checks for the CTFd application:

- **Health Check Path**: `/healthcheck` (CTFd's built-in health endpoint)
- **Protocol**: HTTP
- **Port**: Traffic port (8000)
- **Interval**: 30 seconds
- **Timeout**: 5 seconds
- **Healthy Threshold**: 2 consecutive successes
- **Unhealthy Threshold**: 3 consecutive failures
- **Success Codes**: 200

## SSL Configuration

### Certificate Creation
- **Domain Validation**: DNS-based validation via Route53
- **Subject Alternative Names**: Support for multiple domains
- **Automatic Renewal**: ACM handles certificate renewal

### SSL Policies
Default: `ELBSecurityPolicy-TLS-1-2-2017-01`

Recommended for modern security:
- `ELBSecurityPolicy-TLS-1-2-Ext-2018-06`
- `ELBSecurityPolicy-FS-1-2-Res-2020-10`

## DNS Configuration

### Route53 Setup
1. **Hosted Zone**: Created automatically or use existing
2. **A Record**: Points to ALB with alias
3. **AAAA Record**: IPv6 support
4. **Certificate Validation**: Automatic DNS validation records

### Domain Requirements
- Domain must be registered and configurable
- DNS delegation to Route53 name servers required
- Certificate validation requires DNS control

## Monitoring & Alerting

CloudWatch alarms monitor:

1. **Target Response Time** (>1 second)
2. **Healthy Host Count** (<1 healthy target)
3. **HTTP 5xx Errors** (>5 errors in 5 minutes)
4. **HTTP 4xx Errors** (>20 errors in 5 minutes)

## Production Considerations

### Security
- Enable **deletion protection** for production ALBs
- Configure **WAF v2** for DDoS and application protection
- Enable **access logs** for compliance and debugging
- Use **modern SSL policies** for enhanced security

### Performance
- Configure appropriate **idle timeout** (60-4000 seconds)
- Enable **HTTP/2** for better performance
- Use **cross-zone load balancing** for even distribution

### Cost Optimization
- **Access logs** generate additional S3 charges
- **WAF** adds per-request charges
- **Cross-zone load balancing** may increase data transfer costs

## Troubleshooting

### Common Issues

1. **Certificate Validation Fails**
   - Verify DNS delegation to Route53
   - Check domain ownership
   - Ensure Route53 zone is active

2. **Health Check Failures**
   - Verify CTFd `/healthcheck` endpoint
   - Check security group rules
   - Confirm target group port configuration

3. **SSL Handshake Errors**
   - Update SSL security policy
   - Verify certificate is validated
   - Check client TLS support

4. **DNS Resolution Issues**
   - Verify Route53 name servers
   - Check A/AAAA record configuration
   - Confirm domain delegation

### Debugging Commands

```bash
# Check certificate status
aws acm describe-certificate --certificate-arn <arn>

# Test health check endpoint
curl -f http://<alb-dns>/healthcheck

# Verify DNS resolution
dig ctf.example.com
nslookup ctf.example.com

# Check target group health
aws elbv2 describe-target-health --target-group-arn <arn>
```