variable "env" {
  type        = string
  description = "Deployment environment"
}

variable "bucket_name" {
  type        = string
  description = "S3 bucket name to watch"
}

variable "object_prefix" {
  type        = string
  description = "S3 object key prefix filter"
  default     = ""
}

variable "file_suffixes" {
  type        = list(string)
  description = "S3 object key suffix filter (e.g. .csv, .xlsx)"
  default     = [".xlsx", ".csv", ".parquet"]
}

variable "cluster_arn" {
  type        = string
  description = "ECS cluster ARN"
}

variable "task_definition_arn" {
  type        = string
  description = "ECS task definition ARN"
}

variable "task_role_arn" {
  type        = string
  description = "IAM task role ARN"
}

variable "subnet_ids" {
  type        = list(string)
}

variable "security_group_ids" {
  type        = list(string)
}
