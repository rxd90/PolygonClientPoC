# AWS Settings
provider "aws" {
  region = "eu-west-2"
}

# CW Logging configuration
resource "aws_cloudwatch_log_group" "trustwallet_log_group" {
  name              = "/ecs/trustwallet-service"
  retention_in_days = 7
}

# AWS ECS Cluster
resource "aws_ecs_cluster" "trustwallet-cluster" {
  name = "trustwallet-cluster"
}

resource "aws_ecs_task_definition" "trustwallet-task" {
  family                   = "trustwallet-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "trustwallet"
      image     = "ricard0/trustwallet:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.trustwallet_log_group.name
          awslogs-region        = "eu-west-2"
          awslogs-stream-prefix = "ecs"
        }
      },
      repositoryCredentials = {
        credentialsParameter = aws_secretsmanager_secret.dockerhub_credentials.arn
      }
    }
  ])
}

resource "aws_ecs_service" "trustwallet-service" {
  name            = "trustwallet-service"
  cluster         = aws_ecs_cluster.trustwallet-cluster.id
  task_definition = aws_ecs_task_definition.trustwallet-task.arn
  desired_count   = 1

  launch_type = "FARGATE"
  health_check_grace_period_seconds = 60
  
  load_balancer {
    target_group_arn = aws_lb_target_group.trustwallet_tg.arn
    container_name   = "trustwallet"
    container_port   = 8080
  }

  network_configuration {
    subnets         = concat(data.aws_subnets.public_primary_dev_subnets.ids, data.aws_subnets.public_secondary_dev_subnets.ids)
    security_groups = [ aws_security_group.trustwallet_sg.id ]
    assign_public_ip = true
  }
}
