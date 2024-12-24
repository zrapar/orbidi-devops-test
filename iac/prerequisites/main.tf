# Invoke the "prerequisites" module to set up foundational resources for Terraform usage
module "prerequisites" {
  # Source of the module: relative path to the prerequisites module
  source = "../modules/prerequisites"

  # Pass the AWS region where resources will be created
  aws_region = var.aws_region

  # Configure the backend for storing Terraform state
  backend = {
    group_name  = var.terraform_backend_groupname # Name of the IAM group for backend access
    username    = var.terraform_backend_username  # Name of the IAM user for backend access
    bucket_name = var.s3_backend_name             # Name of the S3 bucket for the backend
  }

  # Define additional users and their IAM group
  users = {
    group_name = var.terraform_groupname # Name of the IAM group for general Terraform users
    usernames = [
      "orbidi-tf-user" # A list of usernames to be created and added to the group
    ]
  }
}
