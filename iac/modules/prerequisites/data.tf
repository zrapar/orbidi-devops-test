# Fetches the identity of the AWS account making the request
data "aws_caller_identity" "current" {}

# IAM policy document for granting Terraform access to S3 backend
data "aws_iam_policy_document" "terraform_access" {
  statement {
    # Define the principal (AWS user) allowed to access the S3 bucket
    principals {
      type        = "AWS"                                        # Principal type (e.g., AWS user)
      identifiers = [aws_iam_user.s3_terraform_backend_user.arn] # ARN of the IAM user
    }

    # Define the actions allowed by the policy
    actions = [
      "s3:PutObject", # Allow putting objects into the S3 bucket
      "s3:GetObject"  # Allow retrieving objects from the S3 bucket
    ]

    # Define the resources the policy applies to
    resources = [
      aws_s3_bucket.backend.arn,        # Access to the S3 bucket itself
      "${aws_s3_bucket.backend.arn}/*", # Access to all objects within the bucket
    ]
  }
}
