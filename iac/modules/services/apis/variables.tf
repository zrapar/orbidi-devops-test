# Environment variable
variable "environment" {
  description = "The environment name for this infrastructure."
  type        = string

  validation {
    condition     = contains(["development", "production"], var.environment)
    error_message = "Invalid Environment. Must be one of development, or production."
  }
}

# Toggle to control resource creation
variable "create" {
  description = "Controls if resources should be created (affects nearly all resources)"
  type        = bool
  default     = true
}

# AWS region
variable "region" {
  description = "The region of AWS to use"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = contains(["us-east-2", "us-east-1", "us-west-1", "us-west-2", "af-south-1", "ap-east-1", "ap-south-2", "ap-southeast-3", "ap-southeast-5", "ap-southeast-4", "ap-south-1", "ap-northeast-3", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ca-central-1", "ca-west-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-south-1", "eu-west-3", "eu-south-2", "eu-north-1", "eu-central-2", "il-central-1", "me-south-1", "me-central-1", "sa-east-1"], var.region)
    error_message = "Invalid AWS Region. Must be one of valid regions (https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html)."
  }
}

# Application configuration
variable "application" {
  description = "The application info to deploy as an ECS Service in AWS"

  type = object({
    name   = string
    cpu    = number
    memory = number
    port   = number
    count  = optional(number, 1)
    domain = string

    image_registry_tag = string

    health_check = object({
      path                  = optional(string, "/")
      health_check_interval = optional(number, 300)
      health_check_timeout  = optional(number, 5)
      unhealthy_threshold   = optional(number, 5)
      healthy_threshold     = optional(number, 2)
    })

    environment_vars = optional(list(object({
      name  = string
      value = string
    })), [])
  })
}

# Other variables are structured similarly, defining configurations for ALB, ECS, VPC, etc.

variable "alb" {
  type = object({
    zone_id           = string
    dns_name          = string
    arn               = string
    arn_suffix        = string
    security_group_id = string
    listeners = map(object({
      id              = string
      arn             = string
      protocol        = string
      certificate_arn = optional(string, "")
    }))
  })
}

variable "ecr" {
  type = object({
    repository_url     = string
    execution_role_arn = string
  })
}

variable "ecs" {
  type = object({
    cluster_name             = string
    cluster_arn              = string
    log_group_name           = string
    secrets_policy           = string
    capacity_providers_names = map(string)
  })
}

variable "vpc" {
  type = object({
    id              = string
    public_subnets  = list(string)
    cidr_block      = string
    private_subnets = list(string)
  })
}
