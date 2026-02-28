module "secrets" {
  source             = "../../modules/secrets"
  env                = var.env
}

module "iam" {
  source             = "../../modules/iam"

  env                = var.env
  input_bucket_arn   = aws_s3_bucket.input.arn
  results_bucket_arn = aws_s3_bucket.results.arn
  db_secret_arn      = module.secrets.db_secret_arn
}

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

module "s3" {
  source            = "../../modules/s3"
  env               = var.env
  system_name       = var.system_name
  tags              = {
  Owner = "data-platform"
  }
}
