data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    key        = var.tf_backend_core_key
    bucket     = var.aws_s3_backend_bucket
    region     = var.aws_s3_backend_region
    access_key = var.aws_s3_backend_access_key
    secret_key = var.aws_s3_backend_secret_key
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"
  config = {
    key        = var.tf_backend_data_key
    bucket     = var.aws_s3_backend_bucket
    region     = var.aws_s3_backend_region
    access_key = var.aws_s3_backend_access_key
    secret_key = var.aws_s3_backend_secret_key
  }
}
