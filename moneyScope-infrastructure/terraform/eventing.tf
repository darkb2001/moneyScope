# Kafka Configuration
resource "aws_msk_configuration" "main" {
  kafka_version = "2.8.1"
  number_of_broker_nodes = 3

  tags = {
    Name = "${var.project_name}-msk-config"
    Environment = var.environment
  }
}

# MSK Subnet Group
resource "aws_msk_cluster" "main" {
  cluster_name           = "${var.project_name}-cluster"
  kafka_version         = aws_msk_configuration.main.kafka_version
  number_of_broker_nodes = aws_msk_configuration.main.number_of_broker_nodes
  broker_node_group_info = [
    {
      instance_type   = "kafka.m5.large"
      client_subnets = [aws_subnet.private[0].id, aws_subnet.private[1].id]
      security_groups = [aws_security_group.msk.id]
    }
  ]

  configuration_info = {
    "auto.create.topics.enable" = "true"
  }

  logging_info = {
    broker_logs = {
      cloudwatch_logs_group_id = "${var.project_name}-msk-logs"
    }
  }

  tags = {
    Name = "${var.project_name}-cluster"
    Environment = var.environment
  }
}

# Kafka Topics
resource "aws_msk_topic" "transaction_created" {
  name             = "transaction.created"
  partitions_count = 3
  replication_factor = 2

  tags = {
    Name = "${var.project_name}-transaction-created"
    Environment = var.environment
  }
}

resource "aws_msk_topic" "transaction_processed" {
  name             = "transaction.processed"
  partitions_count = 3
  replication_factor = 2

  tags = {
    Name = "${var.project_name}-transaction-processed"
    Environment = var.environment
  }
}

resource "aws_msk_topic" "transaction_failed" {
  name             = "transaction.failed"
  partitions_count = 3
  replication_factor = 2

  tags = {
    Name = "${var.project_name}-transaction-failed"
    Environment = var.environment
  }
}

resource "aws_msk_topic" "category_changed" {
  name             = "category.changed"
  partitions_count = 3
  replication_factor = 2

  tags = {
    Name = "${var.project_name}-category-changed"
    Environment = var.environment
  }
}

resource "aws_msk_topic" "saga_commands" {
  name             = "saga.commands"
  partitions_count = 3
  replication_factor = 2

  tags = {
    Name = "${var.project_name}-saga-commands"
    Environment = var.environment
  }
}
