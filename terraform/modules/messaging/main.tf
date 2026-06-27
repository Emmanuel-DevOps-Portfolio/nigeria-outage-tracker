# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.project_name}-outage-dlq"
  message_retention_seconds = 1209600  # 14 days

  tags = {
    Name = "${var.project_name}-outage-dlq"
  }
}

# Main Outage Queue
resource "aws_sqs_queue" "outage_queue" {
  name                       = "${var.project_name}-outage-queue"
  delay_seconds              = 0
  max_message_size           = 262144  # 256KB
  message_retention_seconds  = 86400   # 1 day
  receive_wait_time_seconds  = 10      # long polling
  visibility_timeout_seconds = 30

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name = "${var.project_name}-outage-queue"
  }
}

# SNS Topic for outage alerts
resource "aws_sns_topic" "outage_alerts" {
  name = "${var.project_name}-outage-alerts"

  tags = {
    Name = "${var.project_name}-outage-alerts"
  }
}

# Email subscription
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.outage_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}