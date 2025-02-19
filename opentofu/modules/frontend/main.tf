# Grintric Frontend @ AWS

## Network --------------------------------------------------------
resource "aws_subnet" "frontend" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.1.0/24"
  tags = {
      "project" = var.project_name
  }
}

## Resource -------------------------------------------------------
resource "aws_ecr_repository" "frontend" {
  name = "${var.project_name}-frontend"
}