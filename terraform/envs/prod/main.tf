# --------------------
# Secrets manager
# --------------------
module "secrets" {
  source = "../../modules/secrets"
  env    = var.env
}

# --------------------
# ECS cluster
# --------------------
resource "aws_ecs_cluster" "this" {
  name = "ge-dataquality-validation-${var.env}"
}

# --------------------
# ECS Task Definition
# --------------------
resource "aws_ecs_task_definition" "this" {
  family                   = "ge-dataquality-validation-${var.env}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  task_role_arn      = aws_iam_role.task_role.arn
  execution_role_arn = aws_iam_role.execution_role.arn

  depends_on = [
    aws_cloudwatch_log_group.ecs
  ]

  container_definitions = jsonencode([
    {
      name      = "ge-dataquality-validation"
      image     = var.image_uri
      essential = true

      environment = [
        { name = "APP_ENV", value = var.env },
        { name = "DB_SECRET_ID", value = "dq/db/${var.env}" },
        { name = "AWS_REGION", value = var.aws_region },
        { name = "RESULTS_BUCKET", value = aws_s3_bucket.results.bucket }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/ge-dataquality-validation/${var.env}"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# --------------------
# ECS task assume role
# --------------------
data "aws_iam_policy_document" "ecs_task_assume" {
  statement {
    effect = "Allow"

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }

    actions = ["sts:AssumeRole"]
  }
}

# --------------------
# Task role (runtime)
# --------------------
resource "aws_iam_role" "task_role" {
  name = "ge-dataquality-validation-${var.env}-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

# --------------------
# Secrets Manager read
# --------------------
resource "aws_iam_policy" "secrets_read" {
  name = "ge-dataquality-validation-${var.env}-secrets-read"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "secretsmanager:GetSecretValue"
          ]
          Resource = "arn:aws:secretsmanager:*:*:secret:dq/db/*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "task_secrets" {
  role        = aws_iam_role.task_role.name
  policy_arn  = aws_iam_policy.secrets_read.arn
}

# --------------------
# S3 bucket input
# --------------------
resource "aws_s3_bucket" "input" {
  bucket = "ge-dataquality-input-${var.env}"

  tags = {
    System = "data-quality"
    Env    = var.env
  }
}

# --------------------
# S3 bucket output
# --------------------
resource "aws_s3_bucket" "results" {
  bucket = "ge-dataquality-validation-results-${var.env}"

  tags = {
    System = "data-quality"
    Env    = var.env
  }
}

# --------------------
# S3 access
# --------------------
resource "aws_iam_policy" "s3_access" {
  name = "ge-dataquality-${var.env}-s3-access"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Sid = "ReadInputData"
          Effect = "Allow"
          Action = [
            "s3:GetObject"
          ]
          Resource = [
            "arn:aws:s3:::ge-dataquality-input-${var.env}/*"
          ]
        },
        {
          Sid = "WriteValidationResults"
          Effect = "Allow"
          Action = [
            "s3:PutObject"
          ]
          Resource = [
            "arn:aws:s3:::ge-dataquality-validation-results-${var.env}/*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policy_attachment" "task_s3" {
  role        = aws_iam_role.task_role.name
  policy_arn  = aws_iam_policy.s3_access.arn
}

# --------------------
# Execution role
# --------------------
resource "aws_iam_role" "execution_role" {
  name = "ge-dataquality-validation-${var.env}-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role        =  aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --------------------
# Logs
# --------------------
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/ge-dataquality-validation/${var.env}"
  retention_in_days = 30
}
