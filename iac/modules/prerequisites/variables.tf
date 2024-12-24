# Variable defining the AWS region
variable "aws_region" {
  description = "Region of AWS to use" # Description of the variable
  type        = string                 # Data type: string
}

# Variable defining Terraform backend information
variable "backend" {
  description = "Terraform backend information"
  type = object({
    group_name  = string # Name of the group associated with the backend
    username    = string # Username for the backend IAM user
    bucket_name = string # Name of the S3 bucket for backend
  })
}

# Variable defining Terraform users to create
variable "users" {
  description = "Terraform users to create"
  type = object({
    group_name = string       # Name of the group for Terraform users
    usernames  = list(string) # List of usernames to be created
  })
}
