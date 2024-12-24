module "fastapi" {
  source      = "../../../modules/services/apis"
  region      = var.aws_region
  environment = var.environment

  application = {
    name   = "${var.environment}-fastapi"
    port   = 8000
    count  = 1
    cpu    = 256
    memory = 512
    domain = "dev-fastapi.${local.domains.zrapar}"

    image_registry_tag = "fastapi"

    health_check = {
      path = "/health"
    }

    environment_vars = [
      {
        name  = "SECRET_NAME"
        value = data.terraform_remote_state.data.outputs.aws_secrets_name_db["postgres"]
      },
      {
        name  = "AWS_REGION"
        value = var.aws_region
      }
    ]
  }

  alb = local.apis_configs.alb
  ecr = local.apis_configs.ecr
  ecs = local.apis_configs.ecs
  vpc = local.apis_configs.vpc
}

module "django" {
  source      = "../../../modules/services/apis"
  region      = var.aws_region
  environment = var.environment

  application = {
    name   = "${var.environment}-django"
    port   = 8000
    count  = 1
    cpu    = 256
    memory = 512
    domain = "dev-django.${local.domains.zrapar}"

    image_registry_tag = "django"

    health_check = {
      path = "/health"
    }

    environment_vars = [
      {
        name  = "SECRET_NAME"
        value = data.terraform_remote_state.data.outputs.aws_secrets_name_db["postgres"]
      },
      {
        name  = "AWS_REGION"
        value = var.aws_region
      }
    ]
  }

  alb = local.apis_configs.alb
  ecr = local.apis_configs.ecr
  ecs = local.apis_configs.ecs
  vpc = local.apis_configs.vpc
}
