# variables for the EC2 instance
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

# variables for the security group
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "bastion_sg_id" {
  description = "Security group ID for bastion host"
  type        = string
}

variable "controller_sg_id" {
  description = "Security group ID for control plane"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name"
  type        = string
}

variable "user_data" {
  description = "Startup script to configure worker node"
  type        = string
}

# variables for both resources
variable "name" {
  description = "Name prefix for the bastion host"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}