output "queue_url" {
  description = "URL of the main SQS outage queue"
  value       = aws_sqs_queue.outage_queue.url
}

output "queue_arn" {
  description = "ARN of the main SQS outage queue"
  value       = aws_sqs_queue.outage_queue.arn
}

output "dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  value       = aws_sqs_queue.dlq.arn
}

output "sns_topic_arn" {
  description = "ARN of the SNS outage alerts topic"
  value       = aws_sns_topic.outage_alerts.arn
}