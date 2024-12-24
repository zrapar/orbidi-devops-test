# Prerequisites Module

## Overview

This Terraform module sets up the necessary prerequisites for managing AWS infrastructure. It defines IAM policies, manages Terraform backend access, and sets up configurations for various AWS services.

## Files and Their Purpose

### 1. `main.tf`
- **Purpose**: Defines local variables for IAM policies for multiple AWS services (e.g., EC2, ECS, RDS, etc.).
- **Details**:
  - Uses `templatefile` to load JSON-based IAM policies dynamically.
  - Includes policies for:
    - Auto-scaling
    - EC2
    - ECR
    - ECS
    - IAM
    - Logs
    - RDS
    - Terraform backend (S3).
---
### 2. `data.tf`
- **Purpose**: Defines IAM policy documents and fetches AWS account identity.
- **Details**:
  - Uses `data.aws_caller_identity` to retrieve the account ID of the AWS caller.
  - Defines a policy document (`data.aws_iam_policy_document`) to grant Terraform access to an S3 backend.
---
### 3. `variables.tf`
- **Purpose**: Defines input variables required for this module.
- **Details**:
  - `aws_region`: Specifies the AWS region to use.
  - `backend`: Specifies details about the Terraform backend, such as the S3 bucket name and IAM group.
  - `users`: Specifies Terraform users to be created, including their group name and list of usernames.
---
### 4. `output.tf`
- **Purpose**: Outputs the IAM access keys for both the backend user and any additional users created by this module.
- **Details**:
  - Merges the backend access keys and user access keys into a single output.
  - Marks the output as sensitive to prevent it from being displayed in Terraform CLI output.

---

### 5. `provider.tf`
- **Purpose**: Configures the AWS provider for Terraform with version constraints.
- **Details**:
  - Specifies the provider source as `hashicorp/aws`.
  - Enforces compatibility with any version `~> 5.0`.

---

### 6. `s3-backend-resources.tf`
- **Purpose**: Sets up resources for the Terraform backend, including an S3 bucket, DynamoDB table, and IAM roles/policies.
- **Details**:
  - Creates the S3 bucket and restricts public access to it.
  - Configures a DynamoDB table for state locking.
  - Sets up IAM policies for managing backend access.
  - Generates an IAM user and group specifically for backend management.

---

### 7. `tf-user-resources.tf`
- **Purpose**: Sets up IAM users, groups, and policies for Terraform usage.
- **Details**:
  - Creates a group for Terraform users.
  - Dynamically generates IAM users based on input variables.
  - Attaches relevant policies to the group.
  - Creates access keys for the users.

---
## How to Use

### Prerequisites
1. Ensure you have Terraform installed and properly configured.
2. Create the necessary JSON policy files in the `policies/` directory.

### Inputs
- Pass the required variables when using this module. For example:

```hcl
module "prerequisites" {
  source = "./prerequisites"

  aws_region = "us-west-2"

  backend = {
    group_name  = "terraform-backend"
    username    = "terraform_user"
    bucket_name = "my-terraform-backend"
  }

  users = {
    group_name = "terraform-users"
    usernames  = ["user1", "user2"]
  }
}
```

### Outputs
- This module does not produce direct outputs but sets up IAM policies and prerequisites needed for Terraform workflows.

## Directory Structure

Ensure the following structure for the `prerequisites` module:

```
prerequisites/
├── main.tf
├── data.tf
├── variables.tf
├── policies/
│   ├── autoscaling-policy.json
│   ├── backend-policies.json
│   ├── ec2-policy.json
│   ├── ecr-policy.json
│   ├── ecs-policy.json
│   ├── iam-policy.json
│   ├── logs-policy.json
│   └── rds-policy.json
```

## Notes
- Ensure that the S3 bucket for the Terraform backend is pre-created and accessible.
- The JSON policy files in the `policies/` directory must be valid and meet your security requirements.
- Ensure secure handling of sensitive outputs, such as IAM access keys.
- Regularly review and rotate access keys for enhanced security.
