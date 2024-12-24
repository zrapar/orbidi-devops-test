# Data Module

## Overview

This module is designed to provision AWS resources for database management and secure access. It includes:

- Relational databases (RDS) with engines such as MySQL, PostgreSQL, MSSQL, and MariaDB.
- Secure configurations using Security Groups, SecretsManager, and a Bastion Host.
- Automatic generation of passwords and secrets.

## Files and Their Purpose

### 1. `data.tf`
- **Purpose**: Fetches the latest Amazon Linux 2023 AMI for EC2 instances.

### 2. `main.tf`
- **Purpose**: Manages the creation of:
  - Database instances with different engines and configurations.
  - Security Groups and rules for database communication.
  - Subnet groups for database placement.
  - Secrets in AWS SecretsManager for database credentials and SSH access.

### 3. `output.tf`
- **Purpose**: Outputs sensitive and non-sensitive information about the provisioned resources, such as database credentials, SSH details, and more.

### 4. `provider.tf`
- **Purpose**: Specifies the required Terraform providers (`aws`, `random`).

### 5. `variables.tf`
- **Purpose**: Defines input variables for the module, including:
  - `databases`: Map of databases to create with their respective configurations.
  - `vpc`: VPC information for resource placement.
  - `environment`: Environment name (`development` or `production`).

### 6. `configs/user_data.tpl`
- **Purpose**: Configures EC2 instances with secure SSH access by enabling password authentication.

## Example Usage

### Module Configuration
```hcl
module "data_module" {
  source = "./data"

  create_module = true
  environment   = "production"
  aws_region    = "us-east-1"

  vpc = {
    id             = "vpc-123456"
    name           = "my-vpc"
    subnets        = ["subnet-abc", "subnet-def"]
    autoscaling_sg = "sg-autoscaling"
  }

  databases = {
    db1 = {
      create           = true
      instance_name    = "my-database"
      db_name          = "mydb"
      engine           = "mysql"
      version          = "8.0"
      size             = "db.t3.micro"
      master_username  = "admin"
      storage_size_mib = 20
      port             = 3306
    }
  }
}
```

### Outputs
- `databases`: Contains sensitive database information (e.g., credentials, endpoint, port).
- `nonsensitive_databases`: Contains non-sensitive database information (e.g., endpoint, port).
- `ssh_bastion`: Contains SSH access information for the bastion host.
- `aws_secrets_name_db`: Contains the names of the secrets which contains db information

## Notes
- Always secure the sensitive outputs, such as passwords and keys.
- Rotate credentials periodically for enhanced security.
- Ensure proper IAM permissions for managing AWS resources.
