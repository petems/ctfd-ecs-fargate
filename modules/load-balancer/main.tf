# Data source for Route53 zone (if not creating)
data "aws_route53_zone" "main" {
  count = var.create_route53_zone ? 0 : 1
  name  = var.domain_name
}

# Route53 Hosted Zone
resource "aws_route53_zone" "main" {
  count = var.create_route53_zone ? 1 : 0
  name  = var.domain_name

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-zone"
  })
}

# Local values for zone ID
locals {
  route53_zone_id = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.main[0].zone_id
}

# ACM Certificate
resource "aws_acm_certificate" "main" {
  count             = var.create_acm_certificate ? 1 : 0
  domain_name       = var.domain_name
  subject_alternative_names = var.certificate_subject_alternative_names
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-certificate"
  })
}

# Certificate validation DNS records
resource "aws_route53_record" "cert_validation" {
  for_each = var.create_acm_certificate ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = local.route53_zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "main" {
  count           = var.create_acm_certificate ? 1 : 0
  certificate_arn = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]

  timeouts {
    create = "10m"
  }
}

# Application Load Balancer
resource "aws_lb" "main" {
  name               = var.alb_name != "" ? var.alb_name : "${var.project_name}-${var.environment}-alb"
  load_balancer_type = var.alb_type
  internal           = var.alb_internal
  security_groups    = var.alb_security_group_ids
  subnets            = var.public_subnet_ids

  enable_deletion_protection       = var.enable_deletion_protection
  idle_timeout                    = var.idle_timeout
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_http2                    = var.enable_http2

  dynamic "access_logs" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      bucket  = var.access_logs_bucket
      prefix  = var.access_logs_prefix
      enabled = true
    }
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb"
  })
}

# Target Group
resource "aws_lb_target_group" "main" {
  name        = var.target_group_name != "" ? var.target_group_name : "${var.project_name}-${var.environment}-tg"
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = var.health_check_enabled
    healthy_threshold   = var.health_check_healthy_threshold
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }

  # Ensure target group survives ALB recreation
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-target-group"
  })
}

# HTTP Listener (redirect to HTTPS or forward)
resource "aws_lb_listener" "http" {
  count             = var.enable_http_listener ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = var.http_port
  protocol          = "HTTP"

  default_action {
    type = var.redirect_http_to_https && var.enable_https_listener ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.redirect_http_to_https && var.enable_https_listener ? [1] : []
      content {
        port        = var.https_port
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.redirect_http_to_https && var.enable_https_listener ? [] : [1]
      content {
        target_group {
          arn = aws_lb_target_group.main.arn
        }
      }
    }
  }

  tags = var.tags
}

# HTTPS Listener
resource "aws_lb_listener" "https" {
  count             = var.enable_https_listener ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = var.https_port
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.create_acm_certificate ? aws_acm_certificate_validation.main[0].certificate_arn : var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }

  tags = var.tags
}

# Route53 A Record for ALB
resource "aws_route53_record" "main" {
  zone_id = local.route53_zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# Route53 AAAA Record for ALB (IPv6)
resource "aws_route53_record" "ipv6" {
  zone_id = local.route53_zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# WAF v2 Association (optional)
resource "aws_wafv2_web_acl_association" "main" {
  count        = var.enable_waf ? 1 : 0
  resource_arn = aws_lb.main.arn
  web_acl_arn  = var.waf_web_acl_arn
}

# CloudWatch Alarms for ALB
resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-target-response-time"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ALB target response time"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_healthy_hosts" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-healthy-hosts"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Average"
  threshold           = "1"
  alarm_description   = "This metric monitors ALB healthy host count"
  alarm_actions       = []

  dimensions = {
    TargetGroup  = aws_lb_target_group.main.arn_suffix
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_http_5xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-http-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "5"
  alarm_description   = "This metric monitors ALB 5xx errors"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_http_4xx_errors" {
  alarm_name          = "${var.project_name}-${var.environment}-alb-http-4xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_ELB_4XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "300"
  statistic           = "Sum"
  threshold           = "20"
  alarm_description   = "This metric monitors ALB 4xx errors"
  alarm_actions       = []

  dimensions = {
    LoadBalancer = aws_lb.main.arn_suffix
  }

  tags = var.tags
}