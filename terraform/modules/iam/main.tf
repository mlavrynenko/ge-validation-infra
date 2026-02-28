terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}
# --------------------
# ECS assume role policy
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
  name               = "ge-dataquality-validation-${var.env}-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

# --------------------
# Execution role
# --------------------
resource "aws_iam_role" "execution_role" {
  name               = "ge-dataquality-validation-${var.env}-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume.json
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --------------------
# Secrets Manager read
# --------------------
resource "aws_iam_policy" "secrets_read" {
  name = "ge-dataquality-validation-${var.env}-secrets-read"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = var.db_secret_arn
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_secrets" {
  policy_arn = aws_iam_policy.secrets_read.arn
  role       = aws_iam_role.task_role.name
}

# --------------------
# S3 access
# --------------------
resource "aws_iam_policy" "s3_access" {
  name = "ge-dataquality-validation-${var.env}-s3-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "ReadInputData"
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "${var.input_bucket_arn}/*"
      },
      {
        Sid      = "WriteResults"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${var.results_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "task_s3" {
  policy_arn = aws_iam_policy.s3_access.arn
  role       = aws_iam_role.task_role.name
}
