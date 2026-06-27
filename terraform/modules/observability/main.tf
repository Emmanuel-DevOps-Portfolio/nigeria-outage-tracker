# CloudWatch Log Groups for each Lambda
resource "aws_cloudwatch_log_group" "validator" {
  name              = "/aws/lambda/${var.project_name}-validator"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-validator-logs"
  }
}

resource "aws_cloudwatch_log_group" "enricher" {
  name              = "/aws/lambda/${var.project_name}-enricher"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-enricher-logs"
  }
}

resource "aws_cloudwatch_log_group" "query" {
  name              = "/aws/lambda/${var.project_name}-query"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-query-logs"
  }
}

resource "aws_cloudwatch_log_group" "aggregator" {
  name              = "/aws/lambda/${var.project_name}-aggregator"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-aggregator-logs"
  }
}

# CloudWatch Alarm — Validator errors
resource "aws_cloudwatch_metric_alarm" "validator_errors" {
  alarm_name          = "${var.project_name}-validator-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Validator Lambda is throwing errors"

  dimensions = {
    FunctionName = "${var.project_name}-validator"
  }

  tags = {
    Name = "${var.project_name}-validator-errors"
  }
}

# CloudWatch Alarm — Enricher errors
resource "aws_cloudwatch_metric_alarm" "enricher_errors" {
  alarm_name          = "${var.project_name}-enricher-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Enricher Lambda is throwing errors"

  dimensions = {
    FunctionName = "${var.project_name}-enricher"
  }

  tags = {
    Name = "${var.project_name}-enricher-errors"
  }
}

# CloudWatch Alarm — DLQ messages
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "${var.project_name}-dlq-messages"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Messages are landing in the Dead Letter Queue"

  dimensions = {
    QueueName = "${var.project_name}-outage-dlq"
  }

  tags = {
    Name = "${var.project_name}-dlq-alarm"
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Invocations"
          region = var.aws_region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.project_name}-validator"],
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.project_name}-enricher"],
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.project_name}-query"],
            ["AWS/Lambda", "Invocations", "FunctionName", "${var.project_name}-aggregator"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Errors"
          region = var.aws_region
          period = 60
          stat   = "Sum"
          metrics = [
            ["AWS/Lambda", "Errors", "FunctionName", "${var.project_name}-validator"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.project_name}-enricher"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.project_name}-query"],
            ["AWS/Lambda", "Errors", "FunctionName", "${var.project_name}-aggregator"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Lambda Duration (ms)"
          region = var.aws_region
          period = 60
          stat   = "Average"
          metrics = [
            ["AWS/Lambda", "Duration", "FunctionName", "${var.project_name}-validator"],
            ["AWS/Lambda", "Duration", "FunctionName", "${var.project_name}-enricher"],
            ["AWS/Lambda", "Duration", "FunctionName", "${var.project_name}-query"],
            ["AWS/Lambda", "Duration", "FunctionName", "${var.project_name}-aggregator"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "SQS Queue Depth"
          region = var.aws_region
          period = 60
          stat   = "Average"
          metrics = [
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "${var.project_name}-outage-queue"],
            ["AWS/SQS", "ApproximateNumberOfMessagesVisible", "QueueName", "${var.project_name}-outage-dlq"]
          ]
        }
      }
    ]
  })
}