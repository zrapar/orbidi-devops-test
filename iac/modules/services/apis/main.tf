# Define local variables to organize service configuration and domain information
locals {
  service = {
    name   = var.application.name             # Name of the ECS service
    cpu    = var.application.cpu              # CPU allocation for the service
    memory = var.application.memory           # Memory allocation for the service
    port   = var.application.port             # Port to expose
    count  = try(var.application.count, 1, 1) # Number of service instances (default: 1)

    # Health check configuration
    health_path           = try(var.application.health_check.path, "/", "/")
    health_check_interval = try(var.application.health_check_interval, 300, 300)
    health_check_timeout  = try(var.application.health_check_timeout, 5, 5)
    unhealthy_threshold   = try(var.application.unhealthy_threshold, 5, 5)
    healthy_threshold     = try(var.application.healthy_threshold, 2, 2)

    # ECR and ECS configuration
    ecr_registry           = var.ecr.repository_url
    ecr_execution_role_arn = var.ecr.execution_role_arn
    docker_image           = "${var.ecr.repository_url}:${var.application.image_registry_tag}"
    get_secrets_policy     = var.ecs.secrets_policy

    cluster_name   = var.ecs.cluster_name   # ECS cluster name
    cluster_arn    = var.ecs.cluster_arn    # ECS cluster ARN
    log_group_name = var.ecs.log_group_name # Log group for ECS logs

    capacity_providers_names = var.ecs.capacity_providers_names # Capacity providers

    environment = var.application.environment_vars # Environment variables for the service

    alb = { # Application Load Balancer (ALB) configuration
      arn               = var.alb.arn
      dns_name          = var.alb.dns_name
      arn_suffix        = var.alb.arn_suffix
      security_group_id = var.alb.security_group_id
      listeners         = var.alb.listeners
    }

    vpc_info = { # VPC configuration
      id              = var.vpc.id
      public_subnets  = var.vpc.public_subnets
      cidr_block      = var.vpc.cidr_block
      private_subnets = var.vpc.private_subnets
    }
  }

  # Process domain details
  domain_info = {
    name          = var.application.domain                             # Domain name
    base          = regex("(\\w+\\.\\w+)$", var.application.domain)[0] # Base domain
    has_subdomain = length(split(".", var.application.domain)) > 2     # Subdomain presence
    is_www        = startswith(var.application.domain, "www.")         # Starts with 'www.'
  }

  # Certificate and Cloudflare configuration based on the domain
  certificates_url   = local.domain_info.is_www ? [local.domain_info.base, local.domain_info.name] : (!local.domain_info.has_subdomain ? [local.domain_info.name, format("www.%s", local.domain_info.name)] : [local.domain_info.name])
  cloudflare_records = local.domain_info.is_www ? ["www", "@"] : (!local.domain_info.has_subdomain ? ["www", "@"] : [replace(local.domain_info.name, ".${local.domain_info.base}", "")])
}

# Define an ALB Target Group for the ECS service
resource "aws_lb_target_group" "this" {
  count       = var.create ? 1 : 0
  name        = local.service.name
  port        = local.service.port
  protocol    = "HTTP"
  vpc_id      = local.service.vpc_info.id
  target_type = "ip"

  # Load balancing and health check configuration
  deregistration_delay              = 5
  load_balancing_cross_zone_enabled = true
  load_balancing_algorithm_type     = "weighted_random"
  load_balancing_anomaly_mitigation = "on"

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  health_check {
    enabled             = true
    healthy_threshold   = local.service.healthy_threshold
    interval            = local.service.health_check_interval
    matcher             = "200"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = local.service.health_check_timeout
    unhealthy_threshold = local.service.unhealthy_threshold
    path                = local.service.health_path
  }
}

# Define an ALB Listener Rule for routing traffic
resource "aws_lb_listener_rule" "this" {
  for_each     = var.create ? { for k, listener in local.service.alb.listeners : k => listener if k == "https" } : {}
  listener_arn = each.value.arn

  condition {
    host_header {
      values = [
        for info in local.cloudflare_records : "${info == "@" ? "${data.cloudflare_zone.zone.name}" : "${info}.${data.cloudflare_zone.zone.name}"}"
      ]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }

  tags = {
    Name = "${local.service.name}-rule"
  }
}

# Define Cloudflare DNS Records for the service
resource "cloudflare_record" "this" {
  depends_on      = [module.ecs_service, aws_lb_listener_rule.this]
  count           = var.create ? length(local.cloudflare_records) : 0
  zone_id         = data.cloudflare_zone.zone.id
  name            = local.cloudflare_records[count.index]
  type            = "CNAME"
  comment         = "DNS Record of ${local.service.name} in ${var.environment} env. Managed by Terraform"
  proxied         = true
  allow_overwrite = true
  content         = local.service.alb.dns_name
}
