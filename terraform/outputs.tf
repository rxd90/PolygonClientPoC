output "ecs_cluster_name" {
  value = aws_ecs_cluster.trustwallet-cluster.name
}

output "ecs_service_name" {
  value = aws_ecs_service.trustwallet-service.name
}

output "trustwallet_alb_dns" {
  value = aws_lb.trustwallet_alb.dns_name
}