# Create an ECR repository to store container images
resource "aws_ecr_repository" "repository" {
  count                = local.container_registry.create ? 1 : 0 # Conditionally create the repository based on the value of local.container_registry.create
  name                 = local.container_registry.registry_name  # Name of the ECR repository
  image_tag_mutability = "MUTABLE"                               # Allows image tags to be mutable

  force_delete = true # Allows the repository to be deleted even if it contains images

  image_scanning_configuration {
    scan_on_push = true # Enable image scanning when an image is pushed to the repository
  }
}

# Create an IAM role for ECS task execution
resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.environment}-ecs-task-exec-role" # Name of the IAM role, dynamically based on environment
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com" # The ECS task service is allowed to assume this role
        },
        Action = "sts:AssumeRole" # Allows ECS tasks to assume this role
      }
    ]
  })
}

# Attach the AmazonECSTaskExecutionRolePolicy to the ECS task execution role
resource "aws_iam_policy_attachment" "ecs_task_execution_attach" {
  name       = "${var.environment}-ecs-task-exec-attach"                               # Name of the policy attachment, dynamically based on environment
  roles      = [aws_iam_role.ecs_task_execution.name]                                  # Attach the policy to the previously created ECS task execution role
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy" # Attach the managed policy for ECS task execution
}


# Create a custom IAM policy to allow ECS tasks to pull images from ECR
resource "aws_iam_policy" "ecr_permissions" {
  name        = "${var.environment}-ecr-policy"                     # Name of the policy, dynamically based on environment
  description = "Policy to allow ECS tasks to pull images from ECR" # Description of the policy
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",       # Allow fetching authorization token from ECR
          "ecr:BatchCheckLayerAvailability", # Allow checking availability of image layers
          "ecr:GetDownloadUrlForLayer",      # Allow downloading image layers
          "ecr:BatchGetImage"                # Allow retrieving container images from ECR
        ],
        Resource = "*" # Allow these actions on any ECR repository
      }
    ]
  })
}

# Attach the custom ECR permissions policy to the ECS task execution role
resource "aws_iam_policy_attachment" "ecr_permissions_attach" {
  name       = "${var.environment}-ecr-policy-attach" # Name of the policy attachment, dynamically based on environment
  roles      = [aws_iam_role.ecs_task_execution.name] # Attach the custom ECR permissions policy to the ECS task execution role
  policy_arn = aws_iam_policy.ecr_permissions.arn     # The ARN of the custom policy
}

