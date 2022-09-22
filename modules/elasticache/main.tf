resource "aws_elasticache_cluster" "elastic-redis" {
  cluster_id           = "elastic-redis"
  engine               = "redis"
  node_type            = "cache.r6g.large"
  #node_type            = "cache.r6g.xlarge"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis6.x"
  #engine_version       = "3.2.10"
  port                 = 6379
}


resource "aws_elasticache_cluster" "elastic-memcached" {
  cluster_id           = "elastic-memcached"
  engine               = "memcached"
  node_type            = "cache.r6g.large"
  num_cache_nodes      = 1
  parameter_group_name = "default.memcached1.6"
  port                 = 11211
}