output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "validator_log_group" {
  description = "CloudWatch log group for validator Lambda"
  value       = aws_cloudwatch_log_group.validator.name
}

output "enricher_log_group" {
  description = "CloudWatch log group for enricher Lambda"
  value       = aws_cloudwatch_log_group.enricher.name
}