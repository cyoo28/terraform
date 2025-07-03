variable "controller_name" {
  description = "Name prefix for controller IAM role and instance profile"
  type        = string
}

variable "worker_name" {
  description = "Name prefix for worker IAM role and instance profile"
  type        = string
}

variable "tags" {
  description = "Tags to apply to IAM resources"
  type        = map(string)
  default     = {}
}