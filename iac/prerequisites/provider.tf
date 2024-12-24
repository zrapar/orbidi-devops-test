terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  access_key = var.aws_ak
  secret_key = var.aws_sk
  region     = var.aws_region

  default_tags {
    tags = {
      Environment = "Global"
      Terraform   = "true"
      Owner       = "Orbidi"
      Departament = "DevOps"
    }
  }
}
