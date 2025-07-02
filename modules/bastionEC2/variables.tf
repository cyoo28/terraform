variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default = "ami-05ffe3c48a9991133"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID"
  type        = string
}

variable "volume_size" {
  description = "Root volume size in GiB"
  type        = number
  default     = 8
}

variable "security_group_id" {
  description = "Name for bastion host security group"
  type        = string
}

variable "name" {
  description = "Name prefix for the bastion host"
  type        = string
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}