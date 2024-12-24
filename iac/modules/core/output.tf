# Output the VPC name
output "aws_vpc_name" {
  value = try(local.vpc.name, null) # Return the VPC name if it exists, otherwise null
}

# Output the VPC ID
output "aws_vpc_id" {
  value = try(module.vpc.vpc_id, null) # Return the VPC ID from the VPC module
}

# Output the list of public subnets
output "aws_public_subnets" {
  value = try(module.vpc.public_subnets, null) # Return the public subnets if available
}

# Output the list of private subnets
output "aws_private_subnets" {
  value = try(module.vpc.private_subnets, null) # Return the private subnets if available
}

# Output the VPC CIDR block
output "aws_vpc_cidr_block" {
  value = try(module.vpc.vpc_cidr_block, null) # Return the VPC CIDR block if available
}

# Output the ID of the default security group in the VPC
output "aws_default_security_group_id" {
  value = try(module.vpc.default_security_group_id, null) # Return the security group ID if available
}

# Output the public IP addresses of the NAT gateway(s)
output "aws_nat_gateway_public_ips" {
  value = try([
    for k, nat in module.vpc.nat_public_ips : nat # Return the list of NAT gateway public IPs
  ], [])
}

# Output the ECR repository name
output "aws_ecr_name" {
  value = try(aws_ecr_repository.repository[0].name, null) # Return the repository name if available
}

# Output the ARN of the ECR repository
output "aws_ecr_arn" {
  value = try(aws_ecr_repository.repository[0].arn, null) # Return the repository ARN if available
}

# Output the registry ID of the ECR repository
output "aws_ecr_registry_id" {
  value = try(aws_ecr_repository.repository[0].registry_id, null) # Return the registry ID if available
}

# Output the URL of the ECR repository
output "aws_ecr_repository_url" {
  value = try(aws_ecr_repository.repository[0].repository_url, null) # Return the repository URL if available
}

# Output the ARN of the ECS task execution role
output "aws_ecr_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution.arn # Return the ARN of the ECS task execution role
}

# Output the ECS cluster name
output "aws_ecs_cluster_name" {
  value = try(module.ecs.cluster_name, null) # Return the ECS cluster name if available
}

# Output the ECS cluster ARN
output "aws_ecs_cluster_arn" {
  value = try(module.ecs.cluster_arn, null) # Return the ECS cluster ARN if available
}

# Output the ECS CloudWatch log group name
output "aws_ecs_cluster_logs_group_name" {
  value = try(module.ecs.cloudwatch_log_group_name, null) # Return the CloudWatch log group name if available
}

# Output the ALB zone ID
output "aws_core_alb_zone_id" {
  value = try(module.core_alb.zone_id, null) # Return the ALB zone ID if available
}

# Output the ALB DNS name
output "aws_core_alb_dns_name" {
  value = try(module.core_alb.dns_name, null) # Return the ALB DNS name if available
}

# Output the ALB ARN
output "aws_core_alb_arn" {
  value = try(module.core_alb.arn, null) # Return the ALB ARN if available
}

# Output the ALB ARN suffix
output "aws_core_alb_arn_suffix" {
  value = try(module.core_alb.arn_suffix, null) # Return the ALB ARN suffix if available
}

# Output the security group ID for the ALB
output "aws_core_alb_security_group_id" {
  value = try(module.core_alb.security_group_id, null) # Return the security group ID for ALB if available
}

# Output the ALB listeners (with details like id, arn, protocol, certificate_arn)
output "aws_core_alb_listeners" {
  value = try({
    for key, info in module.core_alb.listeners : key => {
      id              = info.id
      arn             = info.arn
      protocol        = info.protocol
      certificate_arn = info.certificate_arn # List details of the ALB listeners
    }
  }, {})
}

# Output the ARN of the IAM policy for getting secrets
output "aws_get_secrets_policy_arn" {
  value = try(aws_iam_policy.policy_registry[0].arn, null) # Return the policy ARN for secrets access if available
}

# Output the ID of the autoscaling security group for the DB
output "aws_autoscaling_sg" {
  value = try(aws_security_group.autoscaling_db.id, null) # Return the autoscaling security group ID if available
}

# Output the ECS capacity providers used
output "aws_ecs_capacity_providers" {
  value = {
    for k, provider in module.ecs.autoscaling_capacity_providers : k => provider.name # List ECS capacity providers with their names
  }
}
