# IAM group for Terraform users
resource "aws_iam_group" "terraform_group" {
  name = var.users.group_name
}

# Create IAM users specified in the `users.usernames` list
resource "aws_iam_user" "terraform_users" {
  count = length(var.users.usernames)
  name  = var.users.usernames[count.index]
}

# Add each user to the Terraform group
resource "aws_iam_user_group_membership" "terraform_add_user_to_group_management" {
  count = length(var.users.usernames)
  depends_on = [
    aws_iam_group.terraform_group,
    aws_iam_user.terraform_users
  ]
  user = var.users.usernames[count.index]
  groups = [aws_iam_group.terraform_group.name]
}

# Create IAM policies for Terraform users based on local policies
resource "aws_iam_policy" "iam_policies" {
  depends_on = [
    aws_iam_user_group_membership.terraform_add_user_to_group_management
  ]
  for_each = { for k, policy in local.policies : k => policy if k != "backend" }

  name        = "iam-policy-${each.key}"
  description = "Usage of ${each.key} in terraform"
  policy      = each.value
}

# Attach IAM policies to the Terraform group
resource "aws_iam_group_policy_attachment" "attach_policies" {
  depends_on = [
    aws_iam_policy.iam_policies,
    aws_iam_group.terraform_group
  ]
  for_each = { for k, policy in aws_iam_policy.iam_policies : k => policy }

  group      = aws_iam_group.terraform_group.name
  policy_arn = each.value.arn
}

# Create IAM access keys for each user
resource "aws_iam_access_key" "access_keys" {
  for_each = {
    for k, user in var.users.usernames : user => user
  }
  user = each.value
}
