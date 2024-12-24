# VPC module configuration using the Terraform AWS VPC module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws" # Source of the VPC module from the Terraform AWS modules
  version = "~> 5"                          # Version constraint for the VPC module

  create_vpc = var.create_module && local.vpc.create # Create the VPC if both `var.create_module` and `local.vpc.create` are true

  # Name and CIDR block for the VPC
  name = local.vpc.name
  cidr = local.vpc.ip_range
  azs  = local.vpc.azs # Availability Zones to be used for the VPC

  # Define public subnets based on the number of availability zones
  public_subnets = [for k in range(var.vpc.cant_azs) : cidrsubnet(local.vpc.ip_range, 4, k)]
  # Define private subnets based on the number of availability zones
  private_subnets = [for k in range(var.vpc.cant_azs) : cidrsubnet(local.vpc.ip_range, 4, k + var.vpc.cant_azs)]

  # Enable NAT gateway configuration
  enable_nat_gateway   = true
  single_nat_gateway   = true # Only one NAT gateway to be created
  enable_dns_hostnames = true # Enable DNS hostnames for the VPC
  enable_dns_support   = true # Enable DNS support for the VPC

  # Tags for public subnets
  public_subnet_tags = {
    Name = "pubsub-${local.vpc.name}" # Tag the public subnets with the VPC name prefixed by "pubsub"
  }

  # Tags for private subnets
  private_subnet_tags = {
    Name = "prvsub-${local.vpc.name}" # Tag the private subnets with the VPC name prefixed by "prvsub"
  }

  # General tags for the VPC
  tags = {
    Name = local.vpc.name # Tag the VPC with its name
  }
}
