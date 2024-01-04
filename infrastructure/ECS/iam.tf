resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_instance_ecs_policy_attachment" {
  name       = "ecs-instance-ecs-policy-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_policy_attachment" "ecs_instance_cloudwatch_attachment" {
  name       = "ecs-instance-cloudwatch-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_policy" "ecs_instance_custom_policy" {
  name        = "ecs-instance-custom-policy"
  description = "Custom policy for ECS instance role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecs:ListClusters",
          "ecs:DescribeClusters",
          "ecs:RegisterContainerInstance",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Submit*",
          "ecs:Poll*",
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_instance_custom_policy_attachment" {
  name       = "ecs-instance-custom-policy-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = aws_iam_policy.ecs_instance_custom_policy.arn
}

resource "aws_iam_policy" "ecs_instance_ecr_policy" {
  name        = "ecs-instance-ecr-policy"
  description = "Policy for ECS instances to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "ecs_instance_ecr_policy_attachment" {
  name       = "ecs-instance-ecr-policy-attachment"
  roles      = [aws_iam_role.ecs_instance_role.name]
  policy_arn = aws_iam_policy.ecs_instance_ecr_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_iam_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}


# Task execution role
resource "aws_iam_role" "task_execution_role" {
  name = "task-execution-role"
  description        = "For task to make AWS API calls needed for execution"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.task_execution_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_ecr_task_execution_role_policy" {
  policy_arn = aws_iam_policy.ecs_instance_ecr_policy.arn
  role       = aws_iam_role.task_execution_role.name
}