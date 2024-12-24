# IAM group for managing S3 Terraform backend
resource "aws_iam_group" "s3_terraform_backend_group" {
  name = var.backend.group_name
}

# IAM user for Terraform backend
resource "aws_iam_user" "s3_terraform_backend_user" {
  name = var.backend.username
}

# Add backend user to the backend group
resource "aws_iam_user_group_membership" "terraform_add_user_to_group" {
  depends_on = [
    aws_iam_user.s3_terraform_backend_user,
    aws_iam_group.s3_terraform_backend_group
  ]
  user   = aws_iam_user.s3_terraform_backend_user.name
  groups = [aws_iam_group.s3_terraform_backend_group.name]
}

# S3 bucket for Terraform backend state storage
resource "aws_s3_bucket" "backend" {
  depends_on = [aws_iam_user.s3_terraform_backend_user]
  bucket     = var.backend.bucket_name

  tags = {
    Name = "${var.backend.bucket_name}" # Tag the bucket with its name
  }
}

# IAM policy for managing Terraform backend
resource "aws_iam_policy" "iam_policy_terraform_backend" {
  depends_on  = [aws_s3_bucket.backend]
  name        = "iam-policy-terraform-backend"
  description = "Usage of terraform backend"
  policy      = local.policies.backend
}

# Attach the backend policy to the backend group
resource "aws_iam_group_policy_attachment" "attach_policy_s3_user" {
  depends_on = [
    aws_iam_group.s3_terraform_backend_group,
    aws_iam_policy.iam_policy_terraform_backend
  ]
  group      = aws_iam_group.s3_terraform_backend_group.name
  policy_arn = aws_iam_policy.iam_policy_terraform_backend.arn
}

# S3 bucket policy for Terraform access
resource "aws_s3_bucket_policy" "terraform_access" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.terraform_access.json
}

# Restrict public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "block_access_public" {
  bucket                  = aws_s3_bucket.backend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB table for Terraform state locking
resource "aws_dynamodb_table" "terraform_lock" {
  name           = var.backend.bucket_name
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "LockID"
  attribute {
    name = "LockID" # Primary key for the table
    type = "S"      # Type: String
  }
  tags = {
    "Name" = "DynamoDB Terraform State Lock Table"
  }
}

# IAM access key for backend user
resource "aws_iam_access_key" "backend_access_key" {
  user = aws_iam_user.s3_terraform_backend_user.name
}
