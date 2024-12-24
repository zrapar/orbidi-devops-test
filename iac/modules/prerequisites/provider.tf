# Configure Terraform to use the AWS provider with version constraints
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # AWS provider from HashiCorp
      version = "~> 5.0"        # Use any compatible version 5.x
    }
  }
}
