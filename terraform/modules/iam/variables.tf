variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "input_bucket_arn" {
  description = "ARN of input S3 bucket"
  type        = string
}

variable "results_bucket_arn" {
  description = "ARN of results S3 bucket"
  type        = string
}

variable "db_secret_arn" {
  description = "ARN of DB secret"
  type        = string
}
