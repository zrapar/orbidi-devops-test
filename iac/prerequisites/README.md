# Terraform Prerequisites Setup

This project contains Terraform code to set up foundational resources for managing infrastructure across AWS accounts. It includes:
- IAM users and groups for Terraform management.
- S3 bucket configuration as a backend for Terraform state.
- Access keys and policies for secure interaction with AWS resources.

## Prerequisites

Ensure you have the following tools installed:
- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (version >= 1.0.0)
- AWS CLI (optional, for verification)
- An AWS account with administrative credentials.

## Configuration

### Variables

Before running the Terraform code, ensure you define the required variables. You can do this in a `terraform.tfvars` file or pass them directly when running Terraform.

**Required Variables**:
```hcl
terraform_groupname         = "Name of the IAM group for Terraform users"
terraform_backend_groupname = "Name of the IAM group for backend access"
terraform_backend_username  = "Name of the IAM user for backend access"
s3_backend_name             = "Name of the S3 bucket for Terraform state"
aws_region                  = "AWS region (e.g., us-east-1)"
aws_ak                      = "AWS Admin Access Key"
aws_sk                      = "AWS Admin Secret Key"
```

Example `terraform.tfvars` file:
```hcl
terraform_groupname         = "terraform-users"
terraform_backend_groupname = "terraform-backend-group"
terraform_backend_username  = "backend-user"
s3_backend_name             = "my-terraform-backend"
aws_region                  = "us-east-1"
aws_ak                      = "AKIAXXXXXXX"
aws_sk                      = "SECRETXXXXXX"
```

## Execution Steps

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd <repository-folder>/iac/prerequisites
   ```

2. **Initialize Terraform**:
   Run the following command to download the necessary provider plugins and modules:
   ```bash
   terraform init
   ```

3. **Validate the configuration**:
   Ensure your configuration is valid:
   ```bash
   terraform validate
   ```

4. **Plan the changes**:
   Review the changes Terraform will apply to your infrastructure:
   ```bash
   terraform plan
   ```

5. **Apply the configuration**:
   Apply the changes to create resources in AWS:
   ```bash
   terraform apply
   ```

6. **Review the output**:
   After applying, you will receive sensitive outputs such as access keys. Ensure these are stored securely.
   ```bash
   terraform output --json >> keys.json
   ```

## Outputs

The following outputs are generated:

- **`keys`**: Access keys for the backend user and additional users.
  - Includes `ak` (Access Key) and `sk` (Secret Key).
  - Marked as sensitive and should be handled securely.

## Security Notes

- **Sensitive Variables**: Use environment variables or encrypted files to manage sensitive inputs like `aws_ak` and `aws_sk`.
- **Access Keys**: Store the generated keys in a secure credential management system, such as AWS Secrets Manager or HashiCorp Vault.
- **Public Access**: The S3 bucket is configured to block public access for security reasons.

## Cleanup

To delete all resources created by this configuration, run:
```bash
terraform destroy
```

Ensure no critical data resides in the S3 bucket before running the destroy command.

## License

This project is licensed under the MIT License. See the LICENSE file for details.

---

**Happy Terraforming!** 🚀
