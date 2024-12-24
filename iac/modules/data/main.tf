# Local variables to define database configurations and ports
locals {
  parameters = {
    mssql = {
      "14.00" = "default.sqlserver-ex-14.0" # Parameter for MSSQL 14.0
      "15.00" = "default.sqlserver-ex-15.0" # Parameter for MSSQL 15.0
      "16.00" = "default.sqlserver-ex-16.0" # Parameter for MSSQL 16.0
    }
    mariadb = {
      "10.11" = "default.mariadb10.11" # Parameter for MariaDB 10.11
      "11.4"  = "default.mariadb11.4"  # Parameter for MariaDB 11.4
    }
    mysql = {
      "5.7" = "default.mysql5.7" # Parameter for MySQL 5.7
      "8.0" = "default.mysql8.0" # Parameter for MySQL 8.0
    }
    postgres = {
      "14" = "default.postgres14" # Parameter for PostgreSQL 14
      "15" = "default.postgres15" # Parameter for PostgreSQL 15
      "16" = "default.postgres16" # Parameter for PostgreSQL 16
    }
  }

  port = {
    mssql    = 1403 # Port for MSSQL
    mariadb  = 3307 # Port for MariaDB
    mysql    = 3306 # Port for MySQL
    postgres = 5432 # Port for PostgreSQL
  }

  bastion_name = "ssh-bastion-rds" # Name for the SSH bastion
  ssh_user     = "ec2-user"        # Name for the SSH User of the bastion
}

# Random password resource to generate database passwords
resource "random_password" "db_passwords" {
  for_each         = { for k, db in var.databases : k => db if db.create } # For each database to be created
  length           = 18                                                    # Password length
  special          = true                                                  # Allow special characters
  override_special = "!$()_[]{}?"                                          # Allowed special characters
}

# Creating the DB subnet group to associate databases with specific subnets
resource "aws_db_subnet_group" "subnet_group" {
  name        = "${var.vpc.name}-subnet-group"        # Name of the subnet group
  description = "Subnet Group of ${var.vpc.name} VPC" # Description of the subnet group
  subnet_ids  = var.vpc.private_subnets               # Subnet IDs associated with the group
}

# Creating a security group for RDS (Relational Database Service)
resource "aws_security_group" "rds" {
  name        = "${var.vpc.name}-rds-security-group" # Security group name
  description = "Terraform RDS PostgreSQL SG"        # Security group description
  vpc_id      = var.vpc.id                           # VPC ID where the security group will be applied

  # Egress rule (outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "${var.vpc.name}-rds-security-group" # Security group name tag
  }
}

# Creating a security group for traffic from EC2 to databases
resource "aws_security_group" "ec2_db" {
  name        = "${var.vpc.name}-ec2-to-db"                    # Security group name
  description = "Security Group Access From Bastion to RDS DB" # Security group description
  vpc_id      = var.vpc.id                                     # VPC ID

  tags = {
    Name = "${var.vpc.name}-ec2-to-db" # Security group tag
  }
}

# Creating a security group for traffic from database to EC2
resource "aws_security_group" "db_ec2" {
  name        = "${var.vpc.name}-db-to-ec2"                    # Security group name
  description = "Security Group Access From RDS DB to Bastion" # Security group description
  vpc_id      = var.vpc.id                                     # VPC ID

  tags = {
    Name = "${var.vpc.name}-db-to-ec2" # Security group tag
  }
}

# Creating a security group for traffic between databases and autoscaling groups
resource "aws_security_group" "db_autoscaling" {
  name        = "${var.vpc.name}-db-to-asg"                # Security group name
  description = "Security Group Access From RDS DB to ASG" # Security group description
  vpc_id      = var.vpc.id                                 # VPC ID

  tags = {
    Name = "${var.vpc.name}-db-to-asg" # Security group tag
  }
}

# Egress rule to allow EC2 to communicate with databases
resource "aws_security_group_rule" "ec2_db" {
  for_each                 = { for k, db in var.databases : k => db if db.create } # For each database to be created
  type                     = "egress"
  from_port                = each.value.port == 0 ? local.port[each.value.engine] : each.value.port # Port to use
  to_port                  = each.value.port == 0 ? local.port[each.value.engine] : each.value.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ec2_db.id # Security group ID for EC2
  source_security_group_id = aws_security_group.db_ec2.id # Security group ID for databases
}

# Egress rule to allow autoscaling groups to communicate with databases
resource "aws_security_group_rule" "autoscaling_db" {
  for_each                 = { for k, db in var.databases : k => db if db.create }
  type                     = "egress"
  from_port                = each.value.port == 0 ? local.port[each.value.engine] : each.value.port
  to_port                  = each.value.port == 0 ? local.port[each.value.engine] : each.value.port
  protocol                 = "tcp"
  security_group_id        = var.vpc.autoscaling_sg               # Autoscaling security group ID
  source_security_group_id = aws_security_group.db_autoscaling.id # Database security group ID
}

# Ingress rule to allow databases to communicate with EC2
resource "aws_security_group_rule" "db_ec2" {
  for_each                 = { for k, db in var.databases : k => db if db.create }
  type                     = "ingress"
  from_port                = each.value.port == 0 ? local.port[each.value.engine] : each.value.port
  to_port                  = each.value.port == 0 ? local.port[each.value.engine] : each.value.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_ec2.id # Security group ID for databases
  source_security_group_id = aws_security_group.ec2_db.id # Security group ID for EC2
}

# Ingress rule to allow databases to communicate with autoscaling groups
resource "aws_security_group_rule" "db_autoscaling" {
  for_each                 = { for k, db in var.databases : k => db if db.create }
  type                     = "ingress"
  from_port                = each.value.port == 0 ? local.port[each.value.engine] : each.value.port
  to_port                  = each.value.port == 0 ? local.port[each.value.engine] : each.value.port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_autoscaling.id # Security group ID for databases
  source_security_group_id = var.vpc.autoscaling_sg               # Autoscaling security group ID
}

# Creating RDS database instances based on provided configurations
resource "aws_db_instance" "databases" {
  for_each = { for k, db in var.databases : k => db if db.create }

  # Database instance settings
  allocated_storage         = each.value.storage_size_mib
  max_allocated_storage     = each.value.storage_size_mib * 2
  identifier                = lower(each.value.instance_name)                          # Lowercase name for instance
  db_name                   = each.value.engine == "mssql" ? null : each.value.db_name # No db_name for MSSQL
  engine                    = each.value.engine == "mssql" ? "sqlserver-ex" : each.value.engine
  engine_version            = each.value.version
  instance_class            = each.value.size
  username                  = each.value.master_username
  password                  = random_password.db_passwords[each.key].result
  parameter_group_name      = local.parameters[each.value.engine][each.value.version]
  skip_final_snapshot       = true
  apply_immediately         = true
  tags                      = { Name = each.value.instance_name }
  multi_az                  = false
  final_snapshot_identifier = "Ignore"
  vpc_security_group_ids    = ["${aws_security_group.rds.id}", "${aws_security_group.db_ec2.id}", "${aws_security_group.db_autoscaling.id}"]
  db_subnet_group_name      = aws_db_subnet_group.subnet_group.id
}

# Storing database credentials in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_secrets" {
  for_each                = { for k, db in var.databases : k => db if db.create }
  name                    = "${each.value.instance_name}-rds-secret"
  recovery_window_in_days = 0 # No recovery window
}

# Storing the version of database credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "rds_secrets" {
  for_each   = { for k, db in var.databases : k => db if db.create }
  depends_on = [aws_db_instance.databases]
  secret_id  = aws_secretsmanager_secret.rds_secrets[each.key].id
  secret_string = jsonencode({
    USER = each.value.master_username
    HOST = aws_db_instance.databases[each.key].address
    PORT = aws_db_instance.databases[each.key].port
    NAME = aws_db_instance.databases[each.key].db_name
    PASS = random_password.db_passwords[each.key].result
  })
}

# Security group for allowing SSH access to the bastion EC2
resource "aws_security_group" "ssh_access" {
  vpc_id      = var.vpc.id
  name        = "EC2 SSH SG"
  description = "Allow inbound and outbound traffic to EC2 instances from SSH"

  ingress {
    from_port   = 22 # SSH port
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "EC2 SSH SG" # Security group tag
  }
}

# Generating a random password for the SSH bastion
resource "random_password" "bastion" {
  length           = 18
  special          = true
  override_special = "!$()_[]{}?"
  min_special      = 0
}

# Creating SSH key pair for the bastion instance
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "${local.bastion_name}-key"
  create_private_key = true

  tags = {
    Name = "${local.bastion_name}-key"
  }
}

# Creating the EC2 bastion instance with SSH access
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 5"

  name = local.bastion_name

  ami = data.aws_ami.amazon_linux_2023.id

  instance_type          = "t2.micro"
  key_name               = module.key_pair.key_pair_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.ssh_access.id, aws_security_group.ec2_db.id]
  subnet_id              = var.vpc.public_subnets.0

  user_data = templatefile("${path.module}/configs/user_data.tpl", {
    SSH_PASSWORD = random_password.bastion.result
    SSH_USER     = local.ssh_user
  })

  tags = {
    Name = local.bastion_name
  }
}

# Allocating an Elastic IP for the bastion EC2 instance
resource "aws_eip" "instance_ip" {
  depends_on = [module.ec2_instance]
  instance   = module.ec2_instance.id
  domain     = "vpc"

  tags = {
    Name = "EIP EC2 Bastion"
  }
}

# Storing SSH credentials in Secrets Manager
resource "aws_secretsmanager_secret" "ssh_secrets" {
  name                    = "${var.environment}-ssh-info"
  recovery_window_in_days = 0 # No recovery window
}

# Storing the version of SSH credentials in Secrets Manager
resource "aws_secretsmanager_secret_version" "ssh_secrets" {
  depends_on = [module.ec2_instance, aws_eip.instance_ip]
  secret_id  = aws_secretsmanager_secret.ssh_secrets.id
  secret_string = jsonencode({
    SSH_HOST = aws_eip.instance_ip.public_ip
    SSH_USER = local.ssh_user
    SSH_PASS = random_password.bastion.result
  })
}

# Storing the bastion key pair in Secrets Manager
resource "aws_secretsmanager_secret" "bastion_key" {
  name                    = "${var.environment}-bastion-keys"
  recovery_window_in_days = 0 # No recovery window
}

# Storing the version of the bastion key pair in Secrets Manager
resource "aws_secretsmanager_secret_version" "bastion_key" {
  depends_on = [module.key_pair, aws_secretsmanager_secret.bastion_key]
  secret_id  = aws_secretsmanager_secret.bastion_key.id
  secret_string = jsonencode({
    public_key  = module.key_pair.public_key_pem
    private_key = module.key_pair.private_key_pem
  })
}
