# Intric API - Grintric Backend @ AWS

locals {
  repository_url = ""
}

## Network
resource "aws_security_group" "intric" {
  name        = "${var.project_name}-intric-sg"
  description = "Security group for Intric"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Roles
resource "aws_iam_role" "intric_deploy_role" {
  name = "intric-deploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "ecs.amazonaws.com",
            "ecs-tasks.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "intric_deploy_access" {
  name = "intric-deploy-access-policy"
  role = aws_iam_role.intric_deploy_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:*",
          "ecr:*",
          "logs:*",
          "cloudwatch:*",
          "elasticloadbalancing:*",
          "ec2:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Lägg till ECS Task Execution Role policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.intric_deploy_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


## Resources

resource "aws_ecs_task_definition" "intric" {
  family                   = "intric-api"
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "256"
  memory                  = "512"
  execution_role_arn      = aws_iam_role.intric_deploy_role.arn

  container_definitions = jsonencode([
    {
      name  = "intric-api"
      image = "${locals.repository_url}:latest"
      
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/intric-api"
          "awslogs-region"        = "eu-north-1"  # Change to your region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.intric.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.subnet_id]
    security_groups  = [aws_security_group.intric.id]
    assign_public_ip = true
  }
}
