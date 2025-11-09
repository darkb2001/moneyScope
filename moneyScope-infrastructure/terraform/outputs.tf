output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private.*.id
}

output "database_subnet_ids" {
  description = "IDs of the database subnets"
  value       = aws_subnet.database.*.id
}

output "elasticache_subnet_ids" {
  description = "IDs of the ElastiCache subnets"
  value       = aws_subnet.elasticache.*.id
}

output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "kafka_bootstrap_servers" {
  description = "Kafka bootstrap servers"
  value       = aws_msk_cluster.main.bootstrap_brokers
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "auth_service_url" {
  description = "Auth service URL"
  value       = "http://${aws_ecs_service.auth.name}.${aws_lb.main.dns_name}"
}

output "transaction_service_url" {
  description = "Transaction service URL"
  value       = "http://${aws_ecs_service.transaction.name}.${aws_lb.main.dns_name}"
}

output "notification_service_url" {
  description = "Notification service URL"
  value       = "http://${aws_ecs_service.notification.name}.${aws_lb.main.dns_name}"
}

output "notification_logs_table_name" {
  description = "DynamoDB table for notification logs"
  value       = aws_dynamodb_table.notification_logs.name
}

output "notification_templates_table_name" {
  description = "DynamoDB table for notification templates"
  value       = aws_dynamodb_table.notification_templates.name
}

output "notification_templates_bucket_name" {
  description = "S3 bucket for notification templates"
  value       = aws_s3_bucket.notification_templates.id
}
