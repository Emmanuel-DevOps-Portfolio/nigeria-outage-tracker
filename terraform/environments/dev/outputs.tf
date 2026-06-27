output "api_endpoint" {
  description = "HTTP API endpoint URL"
  value       = module.api.api_endpoint
}

output "post_reports_url" {
  description = "URL to submit an outage report"
  value       = "${module.api.api_endpoint}reports"
}

output "get_reports_url" {
  description = "URL to query outage reports"
  value       = "${module.api.api_endpoint}reports"
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.observability.dashboard_name
}

output "table_name" {
  description = "DynamoDB table name"
  value       = module.storage.table_name
}