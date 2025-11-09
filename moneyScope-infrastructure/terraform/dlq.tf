# Dead Letter Queue for Failed Events
resource "aws_sqs_queue" "transaction_failed_dlq" {
  name = "${var.project_name}-transaction-failed-dlq"
  visibility_timeout_seconds = 300
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name = "${var.project_name}-transaction-failed-dlq"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "notification_failed_dlq" {
  name = "${var.project_name}-notification-failed-dlq"
  visibility_timeout_seconds = 300
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name = "${var.project_name}-notification-failed-dlq"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "dlq_logs" {
  name = "${var.project_name}-dlq-logs"

  tags = {
    Name = "${var.project_name}-dlq-logs"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "transaction_failed_dlq_alarm" {
  alarm_name          = "${var.project_name}-transaction-failed-dlq-alarm"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods  = 60
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace          = "AWS/SQS"
  period             = 300
  statistic          = "Sum"
  threshold          = 10
  alarm_actions      = ["arn:aws:sns:publish"]

  tags = {
    Name = "${var.project_name}-transaction-failed-dlq-alarm"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "notification_failed_dlq_alarm" {
  alarm_name          = "${var.project_name}-notification-failed-dlq-alarm"
  comparison_operator   = "GreaterThanThreshold"
  evaluation_periods  = 60
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace          = "AWS/SQS"
  period             = 300
  statistic          = "Sum"
  threshold          = 10
  alarm_actions      = ["arn:aws:sns:publish"]

  tags = {
    Name = "${var.project_name}-notification-failed-dlq-alarm"
    Environment = var.environment
  }
}

resource "aws_sns_topic" "dlq_alerts" {
  name = "${var.project_name}-dlq-alerts"

  tags = {
    Name = "${var.project_name}-dlq-alerts"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "transaction_failed_subscription" {
  topic_arn = aws_sns_topic.dlq_alerts.arn
  protocol    = "email"
  endpoint    = "admin@moneyscope.com"

  tags = {
    Name = "${var.project_name}-transaction-failed-subscription"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "notification_failed_subscription" {
  topic_arn = aws_sns_topic.dlq_alerts.arn
  protocol    = "email"
  endpoint    = "admin@moneyscope.com"

  tags = {
    Name = "${var.project_name}-notification-failed-subscription"
    Environment = var.environment
  }
}
