# ECS Service module for deploying a containerized application
module "ecs_service" {
  source = "terraform-aws-modules/ecs/aws//modules/service"

  # Enable or disable resource creation
  create        = var.create
  name          = local.service.name
  cluster_arn   = local.service.cluster_arn
  cpu           = local.service.cpu
  memory        = local.service.memory
  desired_count = local.service.count

  # Capacity provider configuration for ECS
  requires_compatibilities = ["EC2"]
  capacity_provider_strategy = {
    for k, provider_name in local.service.capacity_providers_names : k => {
      capacity_provider = provider_name
      weight            = 1
      base              = 1
    }
  }

  # Define container configurations
  container_definitions = {
    "${local.service.name}" = {
      image  = local.service.docker_image
      cpu    = local.service.cpu
      memory = local.service.memory
      port_mappings = [{
        name          = local.service.name
        containerPort = local.service.port
        protocol      = "tcp"
      }]

      # Health check for the container
      health_check = {
        command     = ["CMD-SHELL", "curl -sfL ${local.service.port == 80 ? "http://localhost${local.service.health_path}" : "http://localhost:${local.service.port}${local.service.health_path}"} || exit 1"]
        timeout     = 10
        startPeriod = 60
        retries     = 5
      }

      environment = local.service.environment

      readonly_root_filesystem = false

      # CloudWatch logging configuration
      enable_cloudwatch_logging              = true
      create_cloudwatch_log_group            = true
      cloudwatch_log_group_name              = "/aws/ecs/${local.service.cluster_name}/${local.service.name}"
      cloudwatch_log_group_retention_in_days = 7

      log_configuration = {
        logDriver = "awslogs"
      }
    }
  }

  # Load balancer configuration for ECS service
  load_balancer = {
    "${local.service.name}" = {
      target_group_arn = var.create ? aws_lb_target_group.this[0].arn : ""
      container_name   = local.service.name
      container_port   = local.service.port
    }
  }

  # IAM policy for accessing secrets
  tasks_iam_role_policies = {
    secrets_policy = local.service.get_secrets_policy
  }

  # Network and security configurations
  subnet_ids = local.service.vpc_info.private_subnets
  security_group_rules = {
    alb_ingress = {
      type                     = "ingress"
      from_port                = local.service.port
      to_port                  = local.service.port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = local.service.alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # Tags for the ECS service
  tags = {
    Name          = local.service.name
    "ecs-service" = local.service.name
  }
}
