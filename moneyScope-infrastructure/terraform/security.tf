# Secrets Manager for sensitive data
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}-db-password"
  description              = "Database password for ${var.project_name}"
  recovery_window_in_days   = 7

  tags = {
    Name = "${var.project_name}-db-password"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret" "jwt_secret" {
  name                    = "${var.project_name}-jwt-secret"
  description              = "JWT signing secret for ${var.project_name}"
  recovery_window_in_days   = 30

  tags = {
    Name = "${var.project_name}-jwt-secret"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret" "webhook_secret" {
  name                    = "${var.project_name}-webhook-secret"
  description              = "Webhook validation secret for ${var.project_name}"
  recovery_window_in_days   = 30

  tags = {
    Name = "${var.project_name}-webhook-secret"
    Environment = var.environment
  }
}
