# Retrieve the available AWS availability zones
data "aws_availability_zones" "available" {}

# Retrieve the AWS account ID of the current caller (user/role)
data "aws_caller_identity" "current" {}

# Retrieve the recommended ECS-optimized AMI for Amazon Linux 2
data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}
