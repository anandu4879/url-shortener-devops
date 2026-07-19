output "redis_endpoint" {
  value = aws_elasticache_cluster.main.cache_nodes[0].address
}

output "redis_sg_id" {
  value = aws_security_group.redis.id
}