# Outputs sensitive database information
output "databases" {
  sensitive = true # Marks the output as sensitive to hide it in CLI output
  value = {
    for k, db in var.databases : k => {
      id           = aws_db_instance.databases[k].id         # Database ID
      identifier   = aws_db_instance.databases[k].identifier # Database identifier
      db_name      = aws_db_instance.databases[k].db_name    # Database name
      default_user = aws_db_instance.databases[k].username   # Database default username
      pass         = aws_db_instance.databases[k].password   # Database password
      port         = aws_db_instance.databases[k].port       # Database port
      host         = aws_db_instance.databases[k].address    # Database host address
      arn          = aws_db_instance.databases[k].arn        # Database ARN
      endpoint     = aws_db_instance.databases[k].endpoint   # Database endpoint
      users = [
        {
          user = aws_db_instance.databases[k].username # Database user
          pass = aws_db_instance.databases[k].password # User password
        }
      ]
    } if db.create # Only include databases that are created
  }
}

# Outputs non-sensitive database information
output "nonsensitive_databases" {
  value = {
    for k, db in var.databases : k => {
      id           = aws_db_instance.databases[k].id         # Database ID
      identifier   = aws_db_instance.databases[k].identifier # Database identifier
      db_name      = aws_db_instance.databases[k].db_name    # Database name
      default_user = aws_db_instance.databases[k].username   # Default user for the database
      port         = aws_db_instance.databases[k].port       # Database port
      host         = aws_db_instance.databases[k].address    # Database host address
      arn          = aws_db_instance.databases[k].arn        # Database ARN
      endpoint     = aws_db_instance.databases[k].endpoint   # Database endpoint
    } if db.create                                           # Only include databases that are created
  }
}

# Outputs SSH bastion information, including sensitive data
output "ssh_bastion" {
  sensitive = true # Marks the output as sensitive to hide it in CLI output
  value = {
    ssh_host    = aws_eip.instance_ip.public_ip   # Public IP address of the SSH bastion
    ssh_user    = local.ssh_user                  # SSH username for the bastion
    ssh_pass    = random_password.bastion.result  # Password for SSH access
    public_key  = module.key_pair.public_key_pem  # Public key for SSH access
    private_key = module.key_pair.private_key_pem # Private key for SSH access
  }
}

# Outputs the names of AWS Secrets Manager secrets for RDS databases
output "aws_secrets_name_db" {
  value = {
    for k, secret in aws_secretsmanager_secret.rds_secrets : k => secret.name # Names of the secrets for RDS databases
  }
}
