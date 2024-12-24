module "data" {
  source      = "../../../modules/data"
  environment = var.environment
  aws_region  = var.aws_region

  vpc = {
    id              = data.terraform_remote_state.core.outputs.aws_vpc_id
    name            = data.terraform_remote_state.core.outputs.aws_vpc_name
    public_subnets  = data.terraform_remote_state.core.outputs.aws_public_subnets
    private_subnets = data.terraform_remote_state.core.outputs.aws_private_subnets
    autoscaling_sg  = data.terraform_remote_state.core.outputs.aws_autoscaling_sg
  }

  databases = {
    postgres = {
      instance_name    = "orbidi-pg"
      db_name          = "orbidiapi"
      engine           = "postgres"
      version          = "16"
      size             = "db.t3.micro"
      master_username  = "orbidi"
      storage_size_mib = 20
    }
  }
}
