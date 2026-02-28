module "secrets" {
  source = "../../modules/secrets"
  env    = var.env
}

module "s3" {
  source      = "../../modules/s3"
  env         = var.env
  system_name = var.system_name
  tags = {
    Owner = "data-platform"
  }
}

module "iam" {
  source = "../../modules/iam"

  env                = var.env
  input_bucket_arn   = module.s3.input_bucket_arn
  results_bucket_arn = module.s3.results_bucket_arn
  db_secret_arn      = module.secrets.db_secret_arn
}

module "ecs" {
  source = "../../modules/ecs-service"

  aws_region = var.aws_region
  env        = var.env
  image_uri  = var.image_uri

  task_role_arn      = module.iam.task_role_arn
  execution_role_arn = module.iam.execution_role_arn

  results_bucket = module.s3.results_bucket_name
  db_secret_id   = module.secrets.db_secret_name
}

module "s3_event_trigger" {
  source              = "../../modules/eventbridge-s3-trigger"

  env                 = var.env
  bucket_name         = module.s3.input_bucket_name

  object_prefix       = "incoming/"
  file_suffixes       = [".xlsx", ".csv", ".parquet"]

  cluster_arn         = module.ecs.cluster_arn
  task_definition_arn = module.ecs.task_definition_arn
  task_role_arn       = module.iam.task_role_arn

  subnet_ids          = data.aws_subnets.this.ids
  security_group_ids  = [data.aws_security_group.default.id]
}
