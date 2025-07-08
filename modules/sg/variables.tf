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

variable "controller_name" {
  description = "Name prefix for the control plane sg"
  type        = string
}

variable "worker_name" {
  description = "Name prefix for the worker node sg"
  type        = string
}

variable "tags" {
  description = "Tags for the sgs"
  type        = map(string)
  default     = {}
}