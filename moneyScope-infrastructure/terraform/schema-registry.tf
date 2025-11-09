# Schema Registry for Kafka Events
resource "aws_schemas_registry" "main" {
  name = "${var.project_name}-schema-registry"

  tags = {
    Name = "${var.project_name}-schema-registry"
    Environment = var.environment
  }
}
