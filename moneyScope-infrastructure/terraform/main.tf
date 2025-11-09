provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = element(data.aws_availability_zones.names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 3}.0/24"
  availability_zone       = element(data.aws_availability_zones.names, count.index)

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# Associate Route Tables with Subnets
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# RDS Subnet Group
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-sg"
  description = "Allow database traffic"
  vpc_id     = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "${var.project_name}-db-sg"
    Environment = var.environment
  }
}

# RDS Subnet
resource "aws_subnet" "database" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 5}.0/24"
  availability_zone       = element(data.aws_availability_zones.names, count.index)

  tags = {
    Name = "${var.project_name}-db-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "postgres" {
  family = "postgres14"
  description = "PostgreSQL 14 parameter group"

  tags = {
    Name = "${var.project_name}-postgres-params"
    Environment = var.environment
  }
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier     = "${var.project_name}-db"
  engine         = "postgres"
  engine_version = "14.9"
  instance_class  = "db.t3.micro"
  allocated_storage = 20
  storage_type    = "gp2"
  storage_encrypted = true
  db_name        = "moneyscope"
  username       = "moneyscope"
  password       = var.db_password
  parameter_group_name = aws_db_parameter_group.postgres.name
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_db_subnet_group.main.id]
  skip_final_snapshot = true
  publicly_accessible = false

  tags = {
    Name = "${var.project_name}-db"
    Environment = var.environment
  }
}

# ElastiCache Subnet Group
resource "aws_security_group" "elasticache" {
  name        = "${var.project_name}-elasticache-sg"
  description = "Allow Redis traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "${var.project_name}-elasticache-sg"
    Environment = var.environment
  }
}

# ElastiCache Subnet
resource "aws_subnet" "elasticache" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 7}.0/24"
  availability_zone       = element(data.aws_availability_zones.names, count.index)

  tags = {
    Name = "${var.project_name}-elasticache-subnet-${count.index + 1}"
    Environment = var.environment
  }
}

# ElastiCache Replication Group
resource "aws_elasticache_replication_group" "main" {
  description = "Redis replication group for MoneyScope"
  automatic_failover_enabled = true
  multi_az_enabled = true
  at_rest_encryption_enabled = true

  tags = {
    Name = "${var.project_name}-redis-rg"
    Environment = var.environment
  }
}

# ElastiCache Cluster
resource "aws_elasticache_subnet_group" "main" {
  name = "${var.project_name}-redis-subnet-group"
  description = "Subnet group for Redis cluster"

  tags = {
    Name = "${var.project_name}-redis-subnet-group"
    Environment = var.environment
  }
}

# ElastiCache Subnet Group Association
resource "aws_elasticache_subnet_group_association" "main" {
  count          = length(aws_subnet.elasticache)
  subnet_group_id = aws_elasticache_subnet_group.main.id
  subnet_id      = element(aws_subnet.elasticache.*.id, count.index)
}

# ElastiCache Cluster
resource "aws_elasticache_replication_group" "main" {
  description = "Redis replication group for MoneyScope"
  automatic_failover_enabled = true
  multi_az_enabled = true
  at_rest_encryption_enabled = true

  tags = {
    Name = "${var.project_name}-redis-rg"
    Environment = var.environment
  }
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "redis" {
  family = "redis7.x"
  description = "Redis 7.x parameter group"

  tags = {
    Name = "${var.project_name}-redis-params"
    Environment = var.environment
  }
}

# ElastiCache Cluster
resource "aws_elasticache_replication_group" "main" {
  description = "Redis replication group for MoneyScope"
  automatic_failover_enabled = true
  multi_az_enabled = true
  at_rest_encryption_enabled = true

  tags = {
    Name = "${var.project_name}-redis-rg"
    Environment = var.environment
  }
}

# MSK Configuration
resource "aws_msk_configuration" "main" {
  kafka_version = "2.8.1"
  number_of_broker_nodes = 3

  tags = {
    Name = "${var.project_name}-msk-config"
    Environment = var.environment
  }
}

# MSK Subnet Group
resource "aws_security_group" "msk" {
  name        = "${var.project_name}-msk-sg"
  description = "Allow Kafka traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    Name = "${var.project_name}-msk-sg"
    Environment = var.environment
  }
}

# MSK Cluster
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

# S3 Bucket for Reports
resource "aws_s3_bucket" "reports" {
  bucket = "${var.project_name}-reports-${var.environment}"
  acl    = "private"

  tags = {
    Name = "${var.project_name}-reports"
    Environment = var.environment
  }
}

# ECR Repository
resource "aws_ecr_repository" "auth" {
  name                 = "${var.project_name}/auth-service"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "${var.project_name}-auth-repo"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "transaction" {
  name                 = "${var.project_name}/transaction-service"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "${var.project_name}-transaction-repo"
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "notification" {
  name                 = "${var.project_name}/notification-service"
  image_tag_mutability = "MUTABLE"

  tags = {
    Name = "${var.project_name}-notification-repo"
    Environment = var.environment
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
    Environment = var.environment
  }
}

# ECS Task Definitions
resource "aws_ecs_task_definition" "auth" {
  family                   = "${var.project_name}-auth"
  network_mode             = "awsvpc"
  requires_compatibilities    = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.auth_task.arn
  task_role_arn           = aws_iam_role.auth_task.arn

  container_definitions = jsonencode([
    {
      name  = "${var.project_name}-auth",
      image = "${aws_ecr_repository.auth.repository_url}:latest",
      port_mappings = [
        {
          containerPort = 8080,
          hostPort      = 8080
        }
      ],
      environment = [
        {
          name  = "SPRING_PROFILES_ACTIVE",
          value = "dev"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-auth",
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-auth-task"
    Environment = var.environment
  }
}

# ECS Service
resource "aws_ecs_service" "auth" {
  name            = "${var.project_name}-auth-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.auth.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  tags = {
    Name = "${var.project_name}-auth-service"
    Environment = var.environment
  }
}

# DynamoDB Tables for Notification Service

# Notification Logs Table
resource "aws_dynamodb_table" "notification_logs" {
  name           = "${var.project_name}-notification-logs"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  
  attribute {
    name = "id"
    type = "S"
  }
  
  attribute {
    name = "user_id"
    type = "S"
  }
  
  attribute {
    name = "created_at"
    type = "S"
  }
  
  global_secondary_index {
    name     = "UserIndex"
    hash_key = "user_id"
    range_key = "created_at"
    projection_type = "ALL"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  tags = {
    Name        = "${var.project_name}-notification-logs"
    Environment = var.environment
    Service     = "notification"
  }
}

# Notification Templates Table
resource "aws_dynamodb_table" "notification_templates" {
  name           = "${var.project_name}-notification-templates"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "type"
  
  attribute {
    name = "type"
    type = "S"
  }
  
  attribute {
    name = "language"
    type = "S"
  }
  
  global_secondary_index {
    name     = "LanguageIndex"
    hash_key = "language"
    projection_type = "ALL"
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  tags = {
    Name        = "${var.project_name}-notification-templates"
    Environment = var.environment
    Service     = "notification"
  }
}

# S3 Bucket for Notification Templates
resource "aws_s3_bucket" "notification_templates" {
  bucket = "${var.project_name}-notification-templates-${var.environment}"
  
  tags = {
    Name        = "${var.project_name}-notification-templates"
    Environment = var.environment
    Service     = "notification"
  }
}

resource "aws_s3_bucket_versioning" "notification_templates" {
  bucket = aws_s3_bucket.notification_templates.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "notification_templates" {
  bucket = aws_s3_bucket.notification_templates.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "notification_templates" {
  bucket = aws_s3_bucket.notification_templates.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
