# variables for the EC2 instance
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

# variables for the security group
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "local_cidr" {
  description = "CIDR block for your local machine to SSH in (e.g., your public IP/32)"
  type        = string
}

variable "controller_sg_id" {
  description = "Security group ID for control plane"
  type        = string
}

variable "worker_node_sg_id" {
  description = "Security group ID for worker nodes"
  type        = list(string)
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