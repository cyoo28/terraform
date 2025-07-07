variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default = "ami-05ffe3c48a9991133"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.small"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet ID"
  type        = string
}

variable "volume_size" {
  description = "Root volume size in GiB"
  type        = number
  default     = 8
}

variable "volume_type" {
  description = "Root volume size in GiB"
  type        = string
  default     = "gp3"
}

variable "security_group_id" {
  description = "Name for worker node security group"
  type        = string
}


variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "user_data" {
  description = "Startup script to configure control plane"
  type        = string
}

variable "name" {
  description = "Name prefix for the worker node"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}