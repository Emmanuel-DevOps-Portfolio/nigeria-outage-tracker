module "storage" {
  source       = "../../modules/storage"
  project_name = var.project_name
}

module "messaging" {
  source       = "../../modules/messaging"
  project_name = var.project_name
  alert_email  = var.alert_email
}

module "compute" {
  source          = "../../modules/compute"
  project_name    = var.project_name
  queue_arn       = module.messaging.queue_arn
  queue_url       = module.messaging.queue_url
  dlq_arn         = module.messaging.dlq_arn
  table_arn       = module.storage.table_arn
  table_name      = module.storage.table_name
  sns_topic_arn   = module.messaging.sns_topic_arn
  alert_threshold = var.alert_threshold
  lambda_runtime  = var.lambda_runtime
  lambda_timeout  = var.lambda_timeout
  lambda_memory   = var.lambda_memory
}

module "api" {
  source                  = "../../modules/api"
  project_name            = var.project_name
  validator_function_arn  = module.compute.validator_function_arn
  validator_function_name = module.compute.validator_function_name
  query_function_arn      = module.compute.query_function_arn
  query_function_name     = module.compute.query_function_name
}

module "observability" {
  source       = "../../modules/observability"
  project_name = var.project_name
  aws_region   = var.aws_region
}