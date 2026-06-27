resource "aws_dynamodb_table" "outage_events" {
  name         = "${var.project_name}-outage-events"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LGA"
  range_key    = "timestamp"

  attribute {
    name = "LGA"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  attribute {
    name = "state"
    type = "S"
  }

  ttl {
    attribute_name = "expiry"
    enabled        = true
  }

  global_secondary_index {
    name            = "StateIndex"
    hash_key        = "state"
    range_key       = "timestamp"
    projection_type = "ALL"
  }

  tags = {
    Name = "${var.project_name}-outage-events"
  }
}