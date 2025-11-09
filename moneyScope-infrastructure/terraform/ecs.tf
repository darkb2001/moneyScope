# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
    Environment = var.environment
  }
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "auth" {
  family                   = "${var.project_name}-auth"
  network_mode             = "awsvpc"
  requires_compatibilities    = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.auth_task.arn
  task_role_arn           = aws_iam_role.auth_task.arn

  container_definitions = jsonencode([
    {
      name  = "${var.project_name}-auth",
      image = "${aws_ecr_repository.auth.repository_url}:latest",
      port_mappings = [
        {
          containerPort = 8080,
          hostPort      = 8080
        }
      ],
      environment = [
        {
          name  = "SPRING_PROFILES_ACTIVE",
          value = "dev"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-auth",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-auth-task"
    Environment = var.environment
  }
}

# ECS Service
resource "aws_ecs_service" "auth" {
  name            = "${var.project_name}-auth-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.auth.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  tags = {
    Name = "${var.project_name}-auth-service"
    Environment = var.environment
  }
}
