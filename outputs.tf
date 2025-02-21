output "alb_dns" {
  description = "ECS 서비스가 연결된 ALB의 DNS 주소"
  value       = aws_lb.app_lb.dns_name
}

output "rds_endpoint" {
  description = "MySQL RDS 엔드포인트 주소"
  value       = aws_db_instance.rds.endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "Redis 클러스터 엔드포인트 주소"
  value       = "${aws_elasticache_cluster.redis.cache_nodes[0].address}:6379"
}
