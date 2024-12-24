output "databases" {
  value     = module.data.databases
  sensitive = true
}

output "nonsensitive_databases" {
  value = module.data.nonsensitive_databases
}

output "aws_secrets_name_db" {
  value = module.data.aws_secrets_name_db
}

output "ssh_bastion" {
  value     = module.data.ssh_bastion
  sensitive = true
}
