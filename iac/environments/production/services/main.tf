locals {
  apis_configs = {
    alb = {
      zone_id           = try(data.terraform_remote_state.core.outputs.aws_core_alb_zone_id, "")
      dns_name          = try(data.terraform_remote_state.core.outputs.aws_core_alb_dns_name, "")
      arn               = try(data.terraform_remote_state.core.outputs.aws_core_alb_arn, "")
      arn_suffix        = try(data.terraform_remote_state.core.outputs.aws_core_alb_arn_suffix, "")
      security_group_id = try(data.terraform_remote_state.core.outputs.aws_core_alb_security_group_id, "")
      listeners         = try(data.terraform_remote_state.core.outputs.aws_core_alb_listeners, {})
    }

    ecr = {
      repository_url     = try(data.terraform_remote_state.core.outputs.aws_ecr_repository_url, "")
      execution_role_arn = try(data.terraform_remote_state.core.outputs.aws_ecr_execution_role_arn, "")
    }

    ecs = {
      cluster_name             = try(data.terraform_remote_state.core.outputs.aws_ecs_cluster_name, "")
      cluster_arn              = try(data.terraform_remote_state.core.outputs.aws_ecs_cluster_arn, "")
      log_group_name           = try(data.terraform_remote_state.core.outputs.aws_ecs_cluster_logs_group_name, "")
      secrets_policy           = try(data.terraform_remote_state.core.outputs.aws_get_secrets_policy_arn, "")
      capacity_providers_names = try(data.terraform_remote_state.core.outputs.aws_ecs_capacity_providers, {})
    }

    vpc = {
      id              = try(data.terraform_remote_state.core.outputs.aws_vpc_id, "")
      cidr_block      = try(data.terraform_remote_state.core.outputs.aws_vpc_cidr_block, "")
      public_subnets  = try(data.terraform_remote_state.core.outputs.aws_public_subnets, [])
      private_subnets = try(data.terraform_remote_state.core.outputs.aws_private_subnets, [])
    }
  }

  domains = {
    zrapar = "zrapar.site"
  }
}
