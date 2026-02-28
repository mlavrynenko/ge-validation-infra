variable "env" {
  type = string
}

resource "aws_secretsmanager_secret" "db" {
  name = "dq/db/${var.env}"

  description = "Data Quality Engine PostgreSQL credentials (${var.env})"
}
