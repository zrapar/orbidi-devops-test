terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" { key = "environments/development/data/terraform.tfstate" }
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      Environment = var.environment
      Terraform   = "true"
      Owner       = "Orbidi"
      Departament = "DevOps"
    }
  }
}
