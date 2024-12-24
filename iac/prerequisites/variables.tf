# Variable for the Terraform user group name
variable "terraform_groupname" {
  description = "Terraform group across the AWS accounts"
  type        = string # The variable is of type string
}

# Variable for the backend IAM group name
variable "terraform_backend_groupname" {
  description = "Terraform username to use the same backend across the AWS accounts" # IAM group for backend access
  type        = string
}

# Variable for the backend IAM username
variable "terraform_backend_username" {
  description = "Terraform group to use the same backend across the AWS accounts" # IAM user for backend access
  type        = string
}

# Variable for the S3 bucket name used as the Terraform backend
variable "s3_backend_name" {
  description = "S3 name for the backend in Terraform" # Name of the S3 bucket
  type        = string
}

# AWS Configuration Variables

# Variable for specifying the AWS region
variable "aws_region" {
  description = "Region of AWS to use" # Defines the AWS region (e.g., us-east-1)
  type        = string
  default     = "us-east-1"
}

# Variable for the AWS Admin access key
variable "aws_ak" {
  description = "Access Key of Admin to create prerequisites" # AWS access key for administrative user
  type        = string
}

# Variable for the AWS Admin secret key
variable "aws_sk" {
  description = "Secret Key of Admin to create prerequisites" # AWS secret key for administrative user
  type        = string
}
