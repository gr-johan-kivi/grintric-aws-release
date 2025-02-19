# Redis - Grintric Backend @ AWS

locals {
  db_password = "sup3rCal1fr4diList1Exp1alid0ci0s"
}

## Network
resource "aws_security_group" "postgres" {
  name        = "${var.project_name}-sg"
  description = "Security group for PostgreSQL"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Roles
resource "aws_iam_role" "ecs_full_access" {
  name = "ecs-full-access-role"

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

resource "aws_iam_role_policy" "ecs_full_access" {
  name = "ecs-full-access-policy"
  role = aws_iam_role.ecs_full_access.id

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
  role       = aws_iam_role.ecs_full_access.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


## Resources

resource "aws_ecs_task_definition" "pgvector" {
  family                   = var.project_name
  network_mode            = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                     = "512"
  memory                  = "1024"
  
  execution_role_arn = aws_iam_role.ecs_full_access.arn
  task_role_arn      = aws_iam_role.ecs_full_access.arn

  container_definitions = jsonencode([
    {
      name  = "${var.project_name}-pgvector"
      image = "pgvector/pgvector:pg13"
      essential = true
      
      portMappings = [
        {
          containerPort = 5432
          hostPort      = 5432
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "POSTGRES_PASSWORD"
          value = local.db_password
        },
        {
          name  = "POSTGRES_DB"
          value = "vectordb"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region" = "eu-north-1"
          "awslogs-group"         = "/ecs/${var.project_name}"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.pgvector.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.subnet_id]
    security_groups  = [aws_security_group.postgres.id]
    assign_public_ip = true
  }
}
