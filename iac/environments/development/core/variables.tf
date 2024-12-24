################################################################################
# Provider Variables
################################################################################

variable "environment" {
  description = "The environment name for this infrastructure."
  type        = string
  default     = "development"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = contains(["us-east-2", "us-east-1", "us-west-1", "us-west-2", "af-south-1", "ap-east-1", "ap-south-2", "ap-southeast-3", "ap-southeast-5", "ap-southeast-4", "ap-south-1", "ap-northeast-3", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ca-central-1", "ca-west-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-south-1", "eu-west-3", "eu-south-2", "eu-north-1", "eu-central-2", "il-central-1", "me-south-1", "me-central-1", "sa-east-1"], var.aws_region)
    error_message = "Invalid AWS Region. Must be one of valid regions (https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html)."
  }
}

variable "aws_access_key" {
  description = "Access Token of AWS for Prodiver Configs"
  type        = string
}

variable "aws_secret_key" {
  description = "Secret Token of AWS for Prodiver Configs"
  type        = string
}

variable "cloudflare_api_token" {
  description = "Api Token of Cloudflare"
  type        = string
}

################################################################################
# Core Module Variables
################################################################################