################################################################################
# Config Variables
################################################################################

variable "create_module" {
  description = "Handle creation of the module"
  type        = bool
  default     = true
}

variable "environment" {
  description = "The environment name for this infrastructure."
  type        = string

  validation {
    condition     = contains(["development", "production"], var.environment)
    error_message = "Invalid Environment. Must be one of development, or production."
  }
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"

  validation {
    condition     = contains(["us-east-2", "us-east-1", "us-west-1", "us-west-2", "af-south-1", "ap-east-1", "ap-south-2", "ap-southeast-3", "ap-southeast-5", "ap-southeast-4", "ap-south-1", "ap-northeast-3", "ap-northeast-2", "ap-southeast-1", "ap-southeast-2", "ap-northeast-1", "ca-central-1", "ca-west-1", "eu-central-1", "eu-west-1", "eu-west-2", "eu-south-1", "eu-west-3", "eu-south-2", "eu-north-1", "eu-central-2", "il-central-1", "me-south-1", "me-central-1", "sa-east-1"], var.aws_region)
    error_message = "Invalid AWS Region. Must be one of valid regions (https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.RegionsAndAvailabilityZones.html)."
  }
}

variable "vpc" {
  type = object({
    id              = string
    name            = string
    public_subnets  = list(string)
    private_subnets = list(string)
    autoscaling_sg  = string
  })
}

################################################################################
# Databases Variables
################################################################################

variable "databases" {
  type = map(object({
    create           = optional(bool, true)
    instance_name    = string
    db_name          = string
    engine           = string
    version          = string
    size             = string
    master_username  = string
    storage_size_mib = optional(number, 20)
    port             = optional(number, 0)
    users = optional(list(object({
      name  = string
      perms = string
    })), [])
  }))

  validation {
    condition = alltrue([for db in var.databases : contains([
      "mysql",
      "postgres",
      "mssql",
      "mariadb",
    ], db.engine)])
    error_message = "Invalid Engine to choose. Must be one of 'mysql', 'postgres', 'mssql', or 'mariadb'"
  }

  validation {
    condition = alltrue([for db in var.databases : contains([
      "db.t2.small",
      "db.t3.small",
      "db.t4g.small",
      "db.t2.micro",
      "db.t3.micro",
      "db.t4g.micro",
      "db.t2.medium",
      "db.t3.medium",
      "db.t4g.medium",
      "db.c6gd.medium",
      "db.m3.medium"
    ], db.size)])
    error_message = "Invalid size for database. Must be one of the specified sizes."
  }

  validation {
    condition     = alltrue([for db in var.databases : alltrue([for user in db.users : contains(["read", "readwrite", "admin"], user.perms)])])
    error_message = "Invalid user permission. Must be one of 'read', 'readwrite', or 'admin'."
  }

  validation {
    condition = alltrue([for db in var.databases : contains(
      lookup({
        mysql    = ["5.7", "8.0"],
        postgres = ["14", "15", "16"],
        mssql    = ["14.00", "15.00", "16.00"],
        mariadb  = ["10.11", "11.4"]
    }, db.engine, []), db.version)])
    error_message = "Invalid version for the specified engine. Ensure the version matches the engine requirements."
  }
}
