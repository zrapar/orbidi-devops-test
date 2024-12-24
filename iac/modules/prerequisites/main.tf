# Define local variables to manage policies for different AWS services
locals {
  policies = {
    # Policy for autoscaling service
    autoscaling = templatefile("${path.module}/policies/autoscaling-policy.json", {
      AWS_REGION     = var.aws_region                              # AWS region to apply the policy
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id # AWS account ID for the caller
    })

    # Policy for EC2 service
    ec2 = templatefile("${path.module}/policies/ec2-policy.json", {
      AWS_REGION     = var.aws_region
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    })

    # Policy for ECR (Elastic Container Registry) service
    ecr = templatefile("${path.module}/policies/ecr-policy.json", {
      AWS_REGION     = var.aws_region
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    })

    # Policy for ECS (Elastic Container Service)
    ecs = templatefile("${path.module}/policies/ecs-policy.json", {
      AWS_REGION     = var.aws_region
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    })

    # Policy for IAM (Identity and Access Management)
    iam = templatefile("${path.module}/policies/iam-policy.json", {
      AWS_REGION     = var.aws_region
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    })

    # Policy for CloudWatch Logs
    logs = templatefile("${path.module}/policies/logs-policy.json", {
      AWS_REGION     = var.aws_region
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    })

    # Policy for RDS (Relational Database Service)
    rds = templatefile("${path.module}/policies/rds-policy.json", {
      AWS_REGION     = var.aws_region
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    })

    # Policy for Terraform backend (e.g., S3 bucket)
    backend = templatefile("${path.module}/policies/backend-policies.json", {
      AWS_REGION     = var.aws_region
      AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
      S3_NAME        = var.backend.bucket_name # Name of the S3 bucket used as Terraform backend
    })
  }
}
