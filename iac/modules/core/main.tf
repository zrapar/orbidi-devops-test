# Local values to store configurations for the VPC, container registry, and ECS cluster
locals {
  # VPC configuration
  vpc = {
    create      = var.vpc.create                                                          # Whether to create the VPC or not (based on variable input)
    name        = var.vpc.name                                                            # The name of the VPC
    ip_range    = try(var.vpc.ip_range, "192.168.255.0/24")                               # The IP range for the VPC, defaulting to "192.168.255.0/24" if not provided
    description = var.vpc.description                                                     # The description of the VPC
    azs         = slice(data.aws_availability_zones.available.names, 0, var.vpc.cant_azs) # List of availability zones (up to `cant_azs` number)
  }

  # Container registry configuration
  container_registry = {
    create        = var.container_registry.create        # Whether to create the container registry or not (based on variable input)
    registry_name = var.container_registry.registry_name # The name of the container registry
  }

  # ECS cluster configuration
  ecs = {
    create                = var.ecs_cluster.create                # Whether to create the ECS cluster or not (based on variable input)
    cluster_name          = var.ecs_cluster.cluster_name          # The name of the ECS cluster
    username_for_pipeline = var.ecs_cluster.username_for_pipeline # The username for the ECS pipeline
    instance_type         = var.ecs_cluster.ec2_instance_type     # The EC2 instance type to be used for ECS
    # The user data script for initializing ECS instances
    user_data = <<-EOT
        #!/bin/bash

        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${var.ecs_cluster.cluster_name}  # Set the ECS cluster name
        ECS_LOGLEVEL=debug  # Set the ECS log level to debug
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode({ "Name" : "${var.ecs_cluster.cluster_name}" })}  # Tag the ECS container instances with the cluster name
        ECS_ENABLE_TASK_IAM_ROLE=true  # Enable task IAM role for ECS
        EOF
      EOT
  }
}
