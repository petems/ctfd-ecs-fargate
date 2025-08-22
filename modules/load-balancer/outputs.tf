output "load_balancer_id" {
  description = "ID of the load balancer"
  value       = aws_lb.main.id
}

output "load_balancer_arn" {
  description = "ARN of the load balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_arn_suffix" {
  description = "ARN suffix of the load balancer"
  value       = aws_lb.main.arn_suffix
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "load_balancer_hosted_zone_id" {
  description = "Hosted zone ID of the load balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_id" {
  description = "ID of the target group"
  value       = aws_lb_target_group.main.id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

output "target_group_arn_suffix" {
  description = "ARN suffix of the target group"
  value       = aws_lb_target_group.main.arn_suffix
}

output "target_group_name" {
  description = "Name of the target group"
  value       = aws_lb_target_group.main.name
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = var.enable_http_listener ? aws_lb_listener.http[0].arn : null
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = var.enable_https_listener ? aws_lb_listener.https[0].arn : null
}

output "route53_zone_id" {
  description = "ID of the Route53 hosted zone"
  value       = local.route53_zone_id
}

output "route53_zone_name" {
  description = "Name of the Route53 hosted zone"
  value       = var.domain_name
}

output "route53_zone_name_servers" {
  description = "Name servers of the Route53 hosted zone"
  value       = var.create_route53_zone ? aws_route53_zone.main[0].name_servers : null
}

output "acm_certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = var.create_acm_certificate ? aws_acm_certificate_validation.main[0].certificate_arn : var.acm_certificate_arn
}

output "acm_certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = var.create_acm_certificate ? aws_acm_certificate.main[0].domain_name : null
}

output "acm_certificate_status" {
  description = "Status of the ACM certificate"
  value       = var.create_acm_certificate ? aws_acm_certificate.main[0].status : null
}

output "application_url" {
  description = "URL to access the application"
  value       = var.enable_https_listener ? "https://${var.domain_name}" : "http://${var.domain_name}"
}

output "cloudwatch_metric_alarm_ids" {
  description = "CloudWatch metric alarm IDs"
  value = {
    target_response_time = aws_cloudwatch_metric_alarm.alb_target_response_time.id
    healthy_hosts        = aws_cloudwatch_metric_alarm.alb_healthy_hosts.id
    http_5xx_errors      = aws_cloudwatch_metric_alarm.alb_http_5xx_errors.id
    http_4xx_errors      = aws_cloudwatch_metric_alarm.alb_http_4xx_errors.id
  }
}

output "waf_web_acl_association_id" {
  description = "ID of the WAF Web ACL association"
  value       = var.enable_waf ? aws_wafv2_web_acl_association.main[0].id : null
}