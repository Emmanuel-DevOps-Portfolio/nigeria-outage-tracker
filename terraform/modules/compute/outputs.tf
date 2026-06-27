output "validator_function_arn" {
  description = "ARN of the validator Lambda function"
  value       = aws_lambda_function.validator.arn
}

output "validator_function_name" {
  description = "Name of the validator Lambda function"
  value       = aws_lambda_function.validator.function_name
}

output "query_function_arn" {
  description = "ARN of the query Lambda function"
  value       = aws_lambda_function.query.arn
}

output "query_function_name" {
  description = "Name of the query Lambda function"
  value       = aws_lambda_function.query.function_name
}

output "enricher_function_arn" {
  description = "ARN of the enricher Lambda function"
  value       = aws_lambda_function.enricher.arn
}

output "aggregator_function_arn" {
  description = "ARN of the aggregator Lambda function"
  value       = aws_lambda_function.aggregator.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_role.arn
}