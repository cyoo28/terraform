variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
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
}

variable "volume_type" {
  description = "Root volume size in GiB"
  type        = string
}

variable "security_group_ids" {
  description = "Name for control plane security group(s)"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
  default     = ""
}

variable "user_data" {
  description = "Startup script to configure control plane"
  type        = string
  default     = ""
}

variable "assign_public_ip" {
  type    = bool
  default = null
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
