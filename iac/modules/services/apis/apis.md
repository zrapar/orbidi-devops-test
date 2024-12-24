# Services/APIs Module

## Overview

This module automates the deployment of ECS services using AWS infrastructure. It integrates with ECS, ECR, ALB, and Cloudflare to deploy containerized applications with proper load balancing and DNS configuration.

## Files and Their Purpose

### 1. `main.tf`
- **Purpose**: Defines the main resources for the ECS service, including load balancer target groups, listener rules, and Cloudflare DNS records.
- **Details**:
  - Configures health checks for the ECS service.
  - Dynamically generates Cloudflare DNS records based on the domain.

### 2. `data.tf`
- **Purpose**: Retrieves Cloudflare zone information for DNS configuration.
- **Details**:
  - Uses the domain provided in `application.domain` to find the associated Cloudflare zone.

### 3. `ecs-service.tf`
- **Purpose**: Uses a Terraform module to define the ECS service and its configuration.
- **Details**:
  - Sets up container definitions, logging, and health checks for the service.
  - Configures the load balancer to integrate with ECS tasks.

### 4. `variables.tf`
- **Purpose**: Defines all input variables required by the module.
- **Key Variables**:
  - `environment`: Specifies the environment (e.g., `development`, `production`).
  - `application`: Contains ECS service details, such as CPU, memory, port, and health check settings.
  - `alb`: Defines the Application Load Balancer configuration.
  - `ecr`: Contains the ECR repository details for the Docker image.
  - `ecs`: Configures ECS cluster settings and capacity providers.

### 5. `provider.tf`
- **Purpose**: Configures the required providers for Terraform.
- **Details**:
  - AWS provider for ECS, ECR, and ALB.
  - Cloudflare provider for DNS management.

### 6. `output.tf`
- **Purpose**: Provides the service's live URL as output.
- **Details**:
  - Constructs the live URL using the domain provided in the input variables.

## Example Usage

### Module Configuration
```hcl
module "api_service" {
  source = "./services/apis"

  environment = "production"
  create      = true

  application = {
    name               = "my-app"
    cpu                = 512
    memory             = 1024
    port               = 80
    domain             = "api.example.com"
    image_registry_tag = "latest"

    health_check = {
      path                  = "/health"
      health_check_interval = 30
      health_check_timeout  = 5
      unhealthy_threshold   = 3
      healthy_threshold     = 2
    }

    environment_vars = [
      { name = "ENV_VAR_1", value = "value1" },
      { name = "ENV_VAR_2", value = "value2" }
    ]
  }

  alb = {
    zone_id           = "ZONE_ID"
    dns_name          = "api.example.com"
    arn               = "alb-arn"
    arn_suffix        = "alb-arn-suffix"
    security_group_id = "sg-123456"
    listeners = {
      https = { id = "listener-id", arn = "listener-arn", protocol = "HTTPS" }
    }
  }

  ecr = {
    repository_url     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app"
    execution_role_arn = "arn:aws:iam::123456789012:role/my-role"
  }

  ecs = {
    cluster_name             = "my-cluster"
    cluster_arn              = "arn:aws:ecs:us-east-1:123456789012:cluster/my-cluster"
    log_group_name           = "/aws/ecs/my-cluster"
    secrets_policy           = "arn:aws:iam::123456789012:policy/secrets-access-policy"
    capacity_providers_names = { ec2 = "EC2", fargate = "FARGATE" }
  }

  vpc = {
    id              = "vpc-123456"
    public_subnets  = ["subnet-abc", "subnet-def"]
    private_subnets = ["subnet-ghi", "subnet-jkl"]
    cidr_block      = "10.0.0.0/16"
  }
}
```
## Notes
- Ensure proper permissions are set for AWS and Cloudflare credentials.
- Secure sensitive outputs, such as URLs and secrets.