# GR Intric deploy @ AWS

locals {
  project_name = "grintric"
}

module "backend" {
  source = "./modules/backend"
  project_name = local.project_name
}

module "frontend" {
  source = "./modules/frontend"
  project_name = local.project_name
}