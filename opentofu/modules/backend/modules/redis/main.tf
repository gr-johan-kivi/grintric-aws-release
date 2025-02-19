# Redis - Grintric Backend @ AWS

locals {
  redis_port = 6379
  node_type = "cache.t3.micro"
  num_nodes = 1
}

# Networks --------------------------------------------------------------


# Resource --------------------------------------------------------------

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.project_name}-redis"
  engine              = "redis"
  node_type           = "cache.t3.micro"
  num_cache_nodes     = local.num_nodes
  port                = local.redis_port
}
