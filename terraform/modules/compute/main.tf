# IAM Role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-lambda-role"
  }
}

# Basic Lambda execution policy (CloudWatch Logs)
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# SQS access policy
resource "aws_iam_role_policy" "lambda_sqs" {
  name = "${var.project_name}-lambda-sqs-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          var.queue_arn,
          var.dlq_arn
        ]
      }
    ]
  })
}

# DynamoDB access policy
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "${var.project_name}-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          var.table_arn,
          "${var.table_arn}/index/*"
        ]
      }
    ]
  })
}

# SNS publish policy
resource "aws_iam_role_policy" "lambda_sns" {
  name = "${var.project_name}-lambda-sns-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# Zip Lambda function code
data "archive_file" "validator" {
  type        = "zip"
  source_file = "${path.root}/../../functions/validator/handler.py"
  output_path = "${path.root}/../../functions/validator/handler.zip"
}

data "archive_file" "enricher" {
  type        = "zip"
  source_file = "${path.root}/../../functions/enricher/handler.py"
  output_path = "${path.root}/../../functions/enricher/handler.zip"
}

data "archive_file" "query" {
  type        = "zip"
  source_file = "${path.root}/../../functions/query/handler.py"
  output_path = "${path.root}/../../functions/query/handler.zip"
}

data "archive_file" "aggregator" {
  type        = "zip"
  source_file = "${path.root}/../../functions/aggregator/handler.py"
  output_path = "${path.root}/../../functions/aggregator/handler.zip"
}

# Validator Lambda
resource "aws_lambda_function" "validator" {
  function_name    = "${var.project_name}-validator"
  filename         = data.archive_file.validator.output_path
  source_code_hash = data.archive_file.validator.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      QUEUE_URL = var.queue_url
    }
  }

  tags = {
    Name = "${var.project_name}-validator"
  }
}

# Enricher Lambda
resource "aws_lambda_function" "enricher" {
  function_name    = "${var.project_name}-enricher"
  filename         = data.archive_file.enricher.output_path
  source_code_hash = data.archive_file.enricher.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      TABLE_NAME      = var.table_name
      SNS_TOPIC_ARN   = var.sns_topic_arn
      ALERT_THRESHOLD = var.alert_threshold
    }
  }

  tags = {
    Name = "${var.project_name}-enricher"
  }
}

# Query Lambda
resource "aws_lambda_function" "query" {
  function_name    = "${var.project_name}-query"
  filename         = data.archive_file.query.output_path
  source_code_hash = data.archive_file.query.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      TABLE_NAME = var.table_name
    }
  }

  tags = {
    Name = "${var.project_name}-query"
  }
}

# Aggregator Lambda
resource "aws_lambda_function" "aggregator" {
  function_name    = "${var.project_name}-aggregator"
  filename         = data.archive_file.aggregator.output_path
  source_code_hash = data.archive_file.aggregator.output_base64sha256
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.lambda_handler"
  runtime          = var.lambda_runtime
  timeout          = var.lambda_timeout
  memory_size      = var.lambda_memory

  environment {
    variables = {
      TABLE_NAME    = var.table_name
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  tags = {
    Name = "${var.project_name}-aggregator"
  }
}

# SQS trigger for Enricher Lambda
resource "aws_lambda_event_source_mapping" "sqs_enricher" {
  event_source_arn = var.queue_arn
  function_name    = aws_lambda_function.enricher.arn
  batch_size       = 10
  enabled          = true
}