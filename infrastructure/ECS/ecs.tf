resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name

  tags = {
    Name = "end-to-end-ecs-project-cluster",
    managedBy = "Terraform"
  }
}

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family                   = "webservice"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  container_definitions    = <<DEFINITION
  [
    {
      "name": "webservice",
      "image": "492700798506.dkr.ecr.us-east-1.amazonaws.com/hackathon-24:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": ${var.container-port},
          "hostPort": ${var.host-port}
        }
      ],
      "memory": 512,
      "cpu": 256,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/webservice",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "my-app"
        }
      }
    }
  ]
  DEFINITION

  tags = {
    Name = "ecs-task-definition",
    managedBy = "Terraform"
  }
}

resource "aws_ecs_service" "service-webservice" {
  cluster         = aws_ecs_cluster.ecs_cluster.id                  # ECS Cluster ID
  desired_count   = 2                                               # Number of tasks running
  launch_type     = "EC2"                                           # Cluster type [ECS OR FARGATE]
  name            = "ecs-service"                 # Name of service
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn # Attach the task to servicerol

  load_balancer {
    container_name   = "webservice"
    container_port   = var.container-port
    target_group_arn = aws_lb_target_group.TG.arn
  }

  tags = {
    Name = "ecs-service",
    managedBy = "Terraform"
  }

  depends_on = [aws_lb_target_group.TG, aws_lb.alb]
}

resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/webservice"
}
