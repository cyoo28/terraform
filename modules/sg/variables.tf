variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "local_cidr" {
  description = "CIDR block for your local machine to SSH in (e.g., your public IP/32)"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "bastion_name" {
  description = "Name prefix for the bastion host sg"
  type        = string
}

variable "bastion_tags" {
  description = "Additional tags for the bastion host sg"
  type        = map(string)
  default     = {}
}

variable "controller_name" {
  description = "Name prefix for the control plane sg"
  type        = string
}

variable "controller_tags" {
  description = "Additional tags for the control plane sg"
  type        = map(string)
  default     = {}
}

variable "worker_name" {
  description = "Name prefix for the worker node sg"
  type        = string
}

variable "worker_tags" {
  description = "Additional tags for the worker node sg"
  type        = map(string)
  default     = {}
}