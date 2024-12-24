# Handle creation of the module (a global flag to control if resources should be created)
variable "create_module" {
  description = "Handle creation of the module"
  type        = bool
  default     = true
}

# Environment variable to define the environment for the infrastructure (e.g., development, production)
variable "environment" {
  description = "The environment name for this infrastructure."
  type        = string

  validation {
    # Validate that the environment is either development or production
    condition     = contains(["development", "production"], var.environment)
    error_message = "Invalid Environment. Must be one of development, or production."
  }
}

# AWS Region configuration with validation for supported regions
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1" # Default to "us-east-1"

  validation {
    # Validate if the AWS region is one of the allowed regions
    condition     = contains(["us-east-2", "us-east-1", "us-west-1", "us-west-2", "af-south-1", "ap-east-1", "ap-south-2", "ap-southeast-3", "ap-southeast-5", "ap-southeast-4", "ap-south-1", "ap-northeast-3", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ca-central-1", "ca-west-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-south-1", "eu-west-3", "eu-south-2", "eu-north-1", "eu-central-2", "il-central-1", "me-south-1", "me-central-1", "sa-east-1"], var.aws_region)
    error_message = "Invalid AWS Region. Must be one of valid regions (https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html)."
  }
}

################################################################################
# VPC Configuration Variables
################################################################################

# Configuration for the Virtual Private Cloud (VPC)
variable "vpc" {
  description = "Configuration for the VPC in the AWS."

  type = object({
    create      = optional(bool, true)                 # Whether to create the VPC
    name        = string                               # The name of the VPC
    ip_range    = optional(string, "192.168.255.0/24") # CIDR block for the VPC
    description = optional(string, "VPC Description")  # Description of the VPC
    cant_azs    = optional(number, 2)                  # Number of Availability Zones to use
  })

  validation {
    # Validate VPC name length
    condition     = length(var.vpc.name) > 2 && length(var.vpc.name) < 17
    error_message = "The VPC name must be between 2 and 16 characters."
  }

  validation {
    # Validate IP range format for VPC CIDR block
    condition = (
      var.vpc.ip_range == null ||
      can(regex(
        "^(10\\.(\\d{1,3})\\.(\\d{1,3})\\.|172\\.(1[6-9]|2[0-9]|3[0-1])\\.(\\d{1,3})\\.|192\\.168\\.(\\d{1,3})\\.)[0-9]{1,3}/(16|17|18|19|20|21|22|23|24|28)$",
        var.vpc.ip_range
      ))
    )
    error_message = <<-EOT
  Invalid IP range. The IP range must be in CIDR notation, within private address space (RFC1918),
  and the subnet mask must be one of /16, /17, /18, /19, /20, /21, /22, /23, /24, or /28.
  EOT
  }

  validation {
    # Validate number of Availability Zones
    condition     = var.vpc.cant_azs >= 2 && var.vpc.cant_azs <= 5
    error_message = "The amount of Availability of zones to use are more than 1 and less than 6"
  }
}

################################################################################
# Container Registry Configuration Variables
################################################################################

# Configuration for the container registry in ECR (Elastic Container Registry)
variable "container_registry" {
  description = "Configuration for the container registry in ECR."
  type = object({
    create        = optional(bool, true) # Whether to create the container registry
    registry_name = string               # Name of the registry
  })
}

################################################################################
# ECS Cluster Configuration Variables
################################################################################

# Configuration for the ECS Cluster
variable "ecs_cluster" {
  description = "Configuration for the ECS Cluster in the AWS."
  type = object({
    create                = optional(bool, true) # Whether to create the ECS cluster
    cluster_name          = string               # Name of the ECS cluster
    username_for_pipeline = string               # Username for the pipeline
    ec2_instance_type     = string               # EC2 instance type for the ECS cluster
  })
}

################################################################################
# Load Balancer (LB) Variables
################################################################################

# Variables to manage domain names for SSL certificates
variable "domains" {
  description = "Map of domains"
  type        = map(string)
  default = {
    main = "example.com" # Default domain name
  }

  validation {
    # Validate that all domains are valid domain names
    condition = alltrue([
      for key, value in var.domains : can(regex("^([a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,}$", value))
    ])
    error_message = "All domain values must be valid domain names."
  }

  validation {
    # Ensure that the 'main' domain key is always present
    condition     = contains(keys(var.domains), "main")
    error_message = "The map must include a key 'main'."
  }
}
