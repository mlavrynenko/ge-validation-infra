# --------------------
# CloudWatch logs
# --------------------
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/ge-dataquality-validation/${var.env}"
  retention_in_days = 30
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
  cpu                      = var.cpu
  memory                   = var.memory

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

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
        { name = "DB_SECRET_ID", value = var.db_secret_id },
        { name = "AWS_REGION", value = var.aws_region },
        { name = "RESULTS_BUCKET", value = var.results_bucket }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
