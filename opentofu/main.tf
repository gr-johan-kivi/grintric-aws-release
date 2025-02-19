# GR Intric deploy @ AWS

provider "aws" {
  region = "eu-north-1"
}

locals {
  project_name = "grintric"
}

# Global assets -------------------------------------------------------------

## Networks -----------------------------------
resource "aws_vpc" "vpc" {

    cidr_block = "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    tags = {
        "project" = local.project_name
    }
}

resource "aws_internet_gateway" "igw" { 
    vpc_id = aws_vpc.vpc.id
    tags = {
        "project" = local.project_name
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.vpc.id
    
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        "project" = local.project_name
    }
}


## ESC cluster --------------------------------
resource "aws_ecs_cluster" "cluster" {
  name = "${local.project_name}-cluster"
  tags = {
      "project" = local.project_name
  }
}


# Modules -------------------------------------------------------------------

## Backend --------------------------------
module "backend" {
  source = "./modules/backend"
  project_name = local.project_name
  vpc_id = aws_vpc.vpc.id
  cluster_id = aws_ecs_cluster.cluster.id
  route_table_id = aws_route_table.public_rt.id
}

## Frontend -------------------------------
module "frontend" {
  source = "./modules/frontend"
  project_name = local.project_name
  vpc_id = aws_vpc.vpc.id
  cluster_id = aws_ecs_cluster.cluster.id
}