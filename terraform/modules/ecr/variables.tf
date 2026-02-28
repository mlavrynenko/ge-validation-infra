variable "env" {
  type        = string
  description = "Deployment environment"
}

variable "system_name" {
  description = "System identifier used in resource naming"
  type        = string
  default     = "ge-dataquality-validation"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
