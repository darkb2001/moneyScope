# Terraform skeleton for MoneyScope (AWS)
provider "aws" {
  region = var.region
}

# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.0"
  name = "moneyscope-vpc"
  cidr = "10.0.0.0/16"
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets  = ["10.0.1.0/24","10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24","10.0.12.0/24"]
}

# ECR
resource "aws_ecr_repository" "auth" {
  name = "moneyscope-auth"
}

resource "aws_ecr_repository" "transaction" {
  name = "moneyscope-transaction"
}

# ECS cluster
resource "aws_ecs_cluster" "moneyscope" {
  name = "moneyscope-cluster"
}

# MSK (Managed Kafka) - optional
resource "aws_msk_cluster" "kafka" {
  cluster_name = "moneyscope-msk"
  kafka_version = "2.8.1"
  number_of_broker_nodes = 3
  broker_node_group_info {
    instance_type = "kafka.m5.large"
    client_subnets = module.vpc.private_subnets
    security_groups = []
  }
  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
    }
  }
}
