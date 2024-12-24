# Output block to expose IAM access keys for backend and user accounts
output "keys" {
  value = merge(
    {
      # Backend access keys (for Terraform backend user)
      "backend" = {
        ak = aws_iam_access_key.backend_access_key.id     # Access key ID
        sk = aws_iam_access_key.backend_access_key.secret # Secret key
      }
    },
    {
      # Access keys for each user created in the module
      for k, access_key in aws_iam_access_key.access_keys :
      k => {
        ak = access_key.id     # Access key ID
        sk = access_key.secret # Secret key
      }
    }
  )
  sensitive = true # Marked as sensitive to hide it in Terraform output
}
