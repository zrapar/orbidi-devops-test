# IAM policy to allow ECS tasks to access secrets (e.g., from AWS Secrets Manager)
resource "aws_iam_policy" "policy_registry" {
  count       = local.ecs.create ? 1 : 0                   # Create the policy if ECS resources are being created
  name        = "get-secrets"                              # Name of the IAM policy
  path        = "/"                                        # Path for the policy
  description = "${var.environment} policy to get secrets" # Description of the policy

  # The policy allows decryption and access to Secrets Manager secrets
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Decrypt",                   # Allow decryption of data using KMS keys
          "secretsmanager:GetSecretValue", # Allow retrieval of secrets from Secrets Manager
        ]
        Effect   = "Allow" # Grant the permissions specified
        Resource = "*"     # Apply the permissions to all resources
      },
    ]
  })
}

# TLS private key resource to be used for domain certificates
resource "tls_private_key" "this" {
  for_each  = local.ecs.create ? var.domains : {} # Only create for domains if ECS is being created
  algorithm = "RSA"                               # Use RSA as the key algorithm
}

# TLS certificate signing request (CSR) for each domain
resource "tls_cert_request" "this" {
  for_each        = local.ecs.create ? var.domains : {}            # Create for each domain if ECS is being created
  depends_on      = [tls_private_key.this]                         # Ensure the private key is created first
  private_key_pem = tls_private_key.this[each.key].private_key_pem # Use the private key for the CSR

  subject {
    # The common name (CN) will be the domain name or a prefix if "main"
    common_name         = "${each.key == "main" ? split(".", each.value)[0] : each.key} certificate"
    organization        = "Orbidi"
    country             = "CA"
    organizational_unit = "DO"
  }
}

# Cloudflare Origin CA certificate creation for each domain
resource "cloudflare_origin_ca_certificate" "this" {
  for_each           = local.ecs.create ? var.domains : {}              # Create for each domain if ECS is being created
  depends_on         = [tls_cert_request.this]                          # Ensure the CSR is created first
  csr                = tls_cert_request.this[each.key].cert_request_pem # Use CSR to request the certificate
  hostnames          = ["*.${each.value}", each.value]                  # Define the hostnames for the certificate
  request_type       = "origin-rsa"                                     # Type of certificate for Cloudflare
  requested_validity = 5475                                             # Certificate validity in days
}

# ACM certificate resource for AWS
resource "aws_acm_certificate" "this" {
  for_each         = local.ecs.create ? var.domains : {}                         # Create for each domain if ECS is being created
  depends_on       = [cloudflare_origin_ca_certificate.this]                     # Ensure the Cloudflare certificate is created first
  private_key      = tls_private_key.this[each.key].private_key_pem              # Use the private key for the ACM certificate
  certificate_body = cloudflare_origin_ca_certificate.this[each.key].certificate # Use Cloudflare certificate
}

# Security group for autoscaling group to allow access to RDS database
resource "aws_security_group" "autoscaling_db" {
  name        = "${module.vpc.name}-asg-to-db"             # Name of the security group
  description = "Security Group Access From ASG to RDS DB" # Description of the security group
  vpc_id      = module.vpc.vpc_id                          # Associate with the VPC from the VPC module

  # Tags for the security group
  tags = {
    Name = "${module.vpc.name}-asg-to-db"
  }
}

# ECS module configuration for ECS cluster and task definitions
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws" # Use the ECS module from Terraform AWS modules
  version = "~> 5"                          # Version constraint for the module

  create       = local.ecs.create       # Create ECS resources if this is set to true
  cluster_name = local.ecs.cluster_name # Name of the ECS cluster

  # Configure autoscaling capacity provider for ECS EC2 instances
  default_capacity_provider_use_fargate = false # Use EC2 instances instead of Fargate
  autoscaling_capacity_providers = {
    cp_ec2 = {
      auto_scaling_group_arn         = module.ecs_asg.autoscaling_group_arn # Reference autoscaling group ARN
      managed_termination_protection = "ENABLED"                            # Enable termination protection

      managed_scaling = {
        maximum_scaling_step_size = 5         # Maximum scaling step size
        minimum_scaling_step_size = 2         # Minimum scaling step size
        status                    = "ENABLED" # Enable managed scaling
        target_capacity           = 80        # Target capacity for scaling
      }

      default_capacity_provider_strategy = {
        weight = 80 # Weight for scaling strategy
      }
    }
  }

  tags = {
    Name = local.ecs.cluster_name # Tag the ECS cluster with its name
  }
}

# ECS autoscaling group configuration
module "ecs_asg" {
  source  = "terraform-aws-modules/autoscaling/aws" # Use the autoscaling module from Terraform AWS modules
  version = "~> 8"

  create                 = local.ecs.create # Create the ASG if ECS is being created
  create_launch_template = local.ecs.create # Create launch template for instances

  name = "${local.ecs.cluster_name}-asg" # Name of the autoscaling group

  image_id        = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]          # Use ECS optimized AMI
  security_groups = [module.autoscaling_sg.security_group_id, aws_security_group.autoscaling_db.id] # Security groups
  instance_type   = local.ecs.instance_type                                                         # EC2 instance type for autoscaling group
  user_data       = base64encode(local.ecs.user_data)                                               # Base64 encode user data script

  create_iam_instance_profile = true                                     # Create IAM instance profile
  iam_role_name               = local.ecs.cluster_name                   # IAM role for EC2 instances
  iam_role_description        = "ECS role for ${local.ecs.cluster_name}" # Role description
  iam_role_policies = {
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role" # ECS permissions
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"                     # SSM permissions
    secret_policy                       = aws_iam_policy.policy_registry[0].arn                                      # Secret access policy
  }

  vpc_zone_identifier = module.vpc.private_subnets # Use private subnets for the ASG
  health_check_type   = "EC2"                      # EC2 health checks for instances
  min_size            = 2                          # Minimum number of instances
  max_size            = 5                          # Maximum number of instances
  desired_capacity    = 2                          # Desired capacity for the ASG

  autoscaling_group_tags = {
    AmazonECSManaged = true # Tag to indicate ECS managed instances
  }

  protect_from_scale_in = true # Prevent instances from being scaled in

  tags = {
    Name = "${local.ecs.cluster_name}-asg" # Tag the ASG with the ECS cluster name
  }
}

# Security group for the autoscaling group
module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws" # Use the security group module
  version = "~> 5"

  name        = "${var.environment}-as-sg"         # Name of the security group
  description = "Autoscaling group security group" # Description of the security group
  vpc_id      = module.vpc.vpc_id                  # Associate with the VPC

  # Define ingress rules from ALB to the ASG instances
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"                     # Allow HTTP traffic on port 80
      source_security_group_id = module.core_alb.security_group_id # From ALB
    },
    {
      rule                     = "https-443-tcp"                   # Allow HTTPS traffic on port 443
      source_security_group_id = module.core_alb.security_group_id # From ALB
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2 # Two ingress rules

  egress_rules = ["all-all"] # Allow all outbound traffic
}

# ALB module to create the application load balancer for ECS services
module "core_alb" {
  source  = "terraform-aws-modules/alb/aws" # Use the ALB module
  version = "~> 9"

  create = local.ecs.create                  # Create the ALB if ECS is being created
  name   = "${var.environment}-services-alb" # ALB name

  load_balancer_type = "application" # Use application load balancer

  vpc_id  = module.vpc.vpc_id         # VPC for the ALB
  subnets = module.vpc.public_subnets # Subnets for the ALB

  enable_deletion_protection = false # Disable deletion protection
  preserve_host_header       = true  # Preserve the host header

  # Security group rules for inbound and outbound traffic
  security_group_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "Allow inbound HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "Allow inbound HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = module.vpc.vpc_cidr_block # Allow outbound traffic to the VPC
    }
  }

  # Listeners for HTTP and HTTPS traffic
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301" # Redirect HTTP to HTTPS
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"                      # Use TLS 1.2/1.3
      certificate_arn = local.ecs.create ? aws_acm_certificate.this["main"].arn : null # Use ACM certificate
      fixed_response = {
        content_type = "text/plain"
        message_body = "Not found"
        status_code  = "404" # Default response for not found pages
      }
    }
  }
}
