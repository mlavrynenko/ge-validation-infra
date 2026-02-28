# --------------------
# S3 bucket input
# --------------------
resource "aws_s3_bucket" "input" {
  bucket = "${var.system_name}-input-${var.env}"

  tags = merge(
    {
      System = var.system_name
      Env    = var.env
    },
    var.tags
  )
}

# --------------------
# S3 bucket output
# --------------------
resource "aws_s3_bucket" "results" {
  bucket = "${var.system_name}-validation-results-${var.env}"

  tags = merge(
    {
      System = var.system_name
      Env    = var.env
    },
    var.tags
  )
}
