module "core" {
  source = "../../../modules/core"

  environment = var.environment
  aws_region  = var.aws_region

  domains = {
    main = "zrapar.site"
  }

  vpc = {
    name     = "${var.environment}-vpc"
    ip_range = "192.168.16.0/20"
    cant_azs = 3
  }

  container_registry = {
    registry_name = "${var.environment}-orbidi-apis"
  }

  ecs_cluster = {
    cluster_name          = "${var.environment}-cluster"
    username_for_pipeline = "${var.environment}-deployment"
    ec2_instance_type     = "t2.micro"
  }
}
