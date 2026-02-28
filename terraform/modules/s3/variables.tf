variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "system_name" {
  description = "System identifier used in resource naming"
  type        = string
  default     = "ge-dataquality"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}
