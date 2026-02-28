# --------------------
# Secrets
# --------------------
module "secrets" {
  source             = "../../modules/secrets"
  env                = var.env
}

# --------------------
# S3
# --------------------
module "s3" {
  source            = "../../modules/s3"
  env               = var.env
  system_name       = var.system_name
  tags              = {
    Owner = "data-platform"
  }
}

# --------------------
# IAM
# --------------------
module "iam" {
  source             = "../../modules/iam"

  env                = var.env
  input_bucket_arn   = module.s3.input_bucket_arn
  results_bucket_arn = module.s3.results_bucket_arn
  db_secret_arn      = module.secrets.db_secret_arn
}

# --------------------
# ECS
# --------------------
module "ecs" {
  source             = "../../modules/ecs-service"

  aws_region         = var.aws_region
  env                = var.env
  image_uri          = var.image_uri

  task_role_arn      = module.iam.task_role_arn
  execution_role_arn = module.iam.execution_role_arn

  results_bucket     = module.s3.results_bucket_name
  db_secret_id       = module.secrets.db_secret_name
}
