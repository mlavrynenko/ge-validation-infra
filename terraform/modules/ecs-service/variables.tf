variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "image_uri" {
  description = "Container image URI"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "task_role_arn" {
  description = "IAM task role ARN"
  type        = string
}

variable "execution_role_arn" {
  description = "IAM execution role ARN"
  type        = string
}

variable "results_bucket" {
  description = "S3 bucket for validation results"
  type        = string
}

variable "db_secret_id" {
  description = "Secrets Manager secret name or ARN"
  type        = string
}

variable "cpu" {
  description = "Fargate CPU units"
  type        = string
  default     = "512"
}

variable "memory" {
  description = "Fargate memory (MB)"
  type        = string
  default     = "1024"
}
