# Grintric Backend @ AWS

# Network -------------------------------------------------------
resource "aws_subnet" "backend" {
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.2.0/24"
  tags = {
      "project" = var.project_name
  }
}

resource "aws_route_table_association" "public_rta" {
    subnet_id = aws_subnet.backend.id
    route_table_id = var.route_table_id
}

# Resources -------------------------------------------------------

## Repository
resource "aws_ecr_repository" "backend" {
  name = "${var.project_name}-backend"
  tags = {
      "project" = var.project_name
  }
}

# Modules -------------------------------------------------------

module "redis" {
  source = "./modules/redis"
  project_name = var.project_name
  subnet_id = aws_subnet.backend.id
}

module "pgvector" {
  source = "./modules/pgvector"
  project_name = var.project_name
  subnet_id = aws_subnet.backend.id
  vpc_id = var.vpc_id
  cluster_id = var.cluster_id
}
