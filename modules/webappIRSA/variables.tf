variable "webapp_name" {
  description = "Name of the web app (used for naming the IAM role and policy)"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "oidc_provider" {
  description = "OIDC provider URL suffix from EKS (without arn:)"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace where the service account exists"
  type        = string
}

variable "service_account_name" {
  description = "Kubernetes service account name that will assume this IAM role"
  type        = string
}

variable "secret_arns" {
  description = "List of Secrets Manager ARNs the app should be allowed to read"
  type        = list(string)
}

variable "parameter_arns" {
  description = "List of SSM Parameter Store ARNs the app should be allowed to read"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to all IAM resources"
  type        = map(string)
  default     = {}
}