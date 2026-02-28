locals {
  object_key_filters = [
    for suffix in var.file_suffixes : (
      var.object_prefix != ""
      ? { prefix = var.object_prefix, suffix = suffix }
      : { suffix = suffix }
    )
  ]
}

resource "aws_cloudwatch_event_rule" "this" {
  name = "ge-dataquality-validation-${var.env}-s3-trigger"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [var.bucket_name]
      }
      object = {
        key = local.object_key_filters
      }
    }
  })
}

data "aws_iam_policy_document" "eventbridge_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eventbridge_role" {
  name               = "ge-dataquality-validation-${var.env}-eventbridge-s3-role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume.json
}

resource "aws_iam_policy" "eventbridge_ecs_run" {
  name = "ge-dataquality-validation-${var.env}-eventbridge-s3-run"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecs:RunTask"]
        Resource = var.task_definition_arn
      },
      {
        Effect   = "Allow"
        Action   = ["iam:PassRole"]
        Resource = var.task_role_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_ecs_run" {
  role       = aws_iam_role.eventbridge_role.name
  policy_arn = aws_iam_policy.eventbridge_ecs_run.arn
}

resource "aws_cloudwatch_event_target" "ecs" {
  rule     = aws_cloudwatch_event_rule.this.name
  arn      = var.cluster_arn
  role_arn = aws_iam_role.eventbridge_role.arn

  input_transformer {
    input_paths = {
      bucket = "$.detail.bucket.name"
      key    = "$.detail.object.key"
    }

    input_template = jsonencode({
      containerOverrides = [
        {
          name = "ge-dataquality-validation"
          environment = [
            { name = "S3_BUCKET", value = "<bucket>" },
            { name = "S3_KEY", value = "<key>" }
          ]
        }
      ]
    })
  }

  ecs_target {
    task_definition_arn = var.task_definition_arn
    launch_type         = "FARGATE"
    task_count          = 1

    network_configuration {
      subnets          = var.subnet_ids
      security_groups  = var.security_group_ids
      assign_public_ip = true
    }
  }
}
