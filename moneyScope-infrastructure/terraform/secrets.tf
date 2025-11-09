# Secrets Manager for sensitive data
resource "aws_secretsmanager_secret" "jwt_public_key" {
  name                    = "${var.project_name}-jwt-public-key"
  description              = "Public key for JWT verification"
  secret_string           = file("jwt-public-key.pem")
  recovery_window_in_days   = 30

  tags = {
    Name = "${var.project_name}-jwt-public-key"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret" "webhook_secret" {
  name                    = "${var.project_name}-webhook-secret"
  description              = "Webhook validation secret for ${var.project_name}"
  secret_string           = "your-webhook-secret-key"
  recovery_window_in_days   = 30

  tags = {
    Name = "${var.project_name}-webhook-secret"
    Environment = var.environment
  }
}

resource "aws_secretsmanager_secret" "ses_smtp_password" {
  name                    = "${var.project_name}-ses-smtp-password"
  description              = "SMTP password for SES"
  secret_string           = "your-smtp-password"
  recovery_window_in_days   = 30

  tags = {
    Name = "${var.project_name}-ses-smtp-password"
    Environment = var.environment
  }
}
