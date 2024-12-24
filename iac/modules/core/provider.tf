# Define required providers for Terraform
terraform {
  required_providers {
    # AWS provider configuration
    aws = {
      source  = "hashicorp/aws" # The source of the AWS provider from HashiCorp
      version = "~> 5.0"        # Version constraint for the AWS provider (compatible with 5.x versions)
    }

    # Cloudflare provider configuration
    cloudflare = {
      source  = "cloudflare/cloudflare" # The source of the Cloudflare provider
      version = "~> 4.0"                # Version constraint for the Cloudflare provider (compatible with 4.x versions)
    }
  }
}
