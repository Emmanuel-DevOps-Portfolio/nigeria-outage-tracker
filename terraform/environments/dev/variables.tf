variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name used to prefix all resources"
  type        = string
  default     = "outage-tracker"
}

variable "alert_email" {
  description = "Email address to receive outage alert notifications"
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