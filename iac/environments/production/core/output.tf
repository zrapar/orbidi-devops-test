output "aws_vpc_name" {
  value = module.core.aws_vpc_name
}

output "aws_vpc_id" {
  value = module.core.aws_vpc_id
}

output "aws_public_subnets" {
  value = module.core.aws_public_subnets
}

output "aws_private_subnets" {
  value = module.core.aws_private_subnets
}

output "aws_vpc_cidr_block" {
  value = module.core.aws_vpc_cidr_block
}

output "aws_default_security_group_id" {
  value = module.core.aws_default_security_group_id
}

output "aws_nat_gateway_public_ips" {
  value = module.core.aws_nat_gateway_public_ips
}

output "aws_ecr_name" {
  value = module.core.aws_ecr_name
}

output "aws_ecr_arn" {
  value = module.core.aws_ecr_arn
}

output "aws_ecr_registry_id" {
  value = module.core.aws_ecr_registry_id
}

output "aws_ecr_repository_url" {
  value = module.core.aws_ecr_repository_url
}

output "aws_ecr_execution_role_arn" {
  value = module.core.aws_ecr_execution_role_arn
}

output "aws_ecs_cluster_name" {
  value = module.core.aws_ecs_cluster_name
}

output "aws_ecs_cluster_arn" {
  value = module.core.aws_ecs_cluster_arn
}

output "aws_ecs_cluster_logs_group_name" {
  value = module.core.aws_ecs_cluster_logs_group_name
}

output "aws_core_alb_zone_id" {
  value = module.core.aws_core_alb_zone_id
}

output "aws_core_alb_dns_name" {
  value = module.core.aws_core_alb_dns_name
}

output "aws_core_alb_arn" {
  value = module.core.aws_core_alb_arn
}

output "aws_core_alb_arn_suffix" {
  value = module.core.aws_core_alb_arn_suffix
}

output "aws_core_alb_security_group_id" {
  value = module.core.aws_core_alb_security_group_id
}

output "aws_core_alb_listeners" {
  value = module.core.aws_core_alb_listeners
}

output "aws_autoscaling_sg" {
  value = module.core.aws_autoscaling_sg
}

output "aws_get_secrets_policy_arn" {
  value = module.core.aws_get_secrets_policy_arn
}

output "aws_ecs_capacity_providers" {
  value = module.core.aws_ecs_capacity_providers
}
