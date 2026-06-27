variable "project_name" {
  description = "Project name used to prefix all resources"
  type        = string
}

variable "queue_arn" {
  description = "queue arn"
  type = string
}

variable "dlq_arn" {
  description = "dead letter queue arn"
  type = string
}

variable "table_arn" {
  description = "table arn"
  type = string
}

variable "sns_topic_arn" {
  description = "sns topic arn"
  type = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "queue_url" {
  description = "SQS queue URL"
  type        = string
}

variable "alert_threshold" {
  description = "Number of reports before SNS alert is triggered"
  type        = number
  default     = 3
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.12"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory" {
  description = "Lambda memory in MB"
  type        = number
  default     = 128
}