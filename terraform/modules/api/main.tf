# HTTP API
resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
  }

  tags = {
    Name = "${var.project_name}-api"
  }
}

# API Stage
resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  tags = {
    Name = "${var.project_name}-api-stage"
  }
}

# Lambda integrations
resource "aws_apigatewayv2_integration" "validator" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.validator_function_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "query" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.query_function_arn
  payload_format_version = "2.0"
}

# Routes
resource "aws_apigatewayv2_route" "post_reports" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "POST /reports"
  target    = "integrations/${aws_apigatewayv2_integration.validator.id}"
}

resource "aws_apigatewayv2_route" "get_reports" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "GET /reports"
  target    = "integrations/${aws_apigatewayv2_integration.query.id}"
}

# Lambda permissions for API Gateway
resource "aws_lambda_permission" "validator" {
  statement_id  = "AllowAPIGatewayInvokeValidator"
  action        = "lambda:InvokeFunction"
  function_name = var.validator_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

resource "aws_lambda_permission" "query" {
  statement_id  = "AllowAPIGatewayInvokeQuery"
  action        = "lambda:InvokeFunction"
  function_name = var.query_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}