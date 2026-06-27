variable "project_name" {
  description = "Project name used to prefix all resources"
  type        = string
}

variable "validator_function_arn" {
  description = "ARN of the validator Lambda function"
  type        = string
}

variable "validator_function_name" {
  description = "Name of the validator Lambda function"
  type        = string
}

variable "query_function_arn" {
  description = "ARN of the query Lambda function"
  type        = string
}

variable "query_function_name" {
  description = "Name of the query Lambda function"
  type        = string
}