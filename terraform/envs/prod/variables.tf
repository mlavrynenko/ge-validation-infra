variable "env" {
  description = "Deployment environment name"
  type        = string
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
}

variable "image_uri" {
  description = "Docker image URI for validation service"
  type        = string
}

variable "system_name" {
  description = "System identifier used in resource naming"
  type        = string
  default     = "ge-dataquality-validation"
}
