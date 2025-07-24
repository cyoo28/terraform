variable "ami_id" {
  type        = string
  description = "AMI ID for instances"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "key_name" {
  type        = string
  description = "SSH key pair name"
}

variable "iam_instance_profile_name" {
  type        = string
  description = "IAM Instance Profile name"
}

variable "user_data" {
  type        = string
  description = "User data script (raw string)"
  default     = ""
}

variable "volume_size" {
  type        = number
  description = "Root EBS volume size in GiB"
}

variable "volume_type" {
  type        = string
  description = "Root EBS volume type (e.g., gp3)"
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to attach"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the ASG"
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances"
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the instances"
  default     = {}
}

variable "name" {
  type        = string
  description = "Prefix for naming resources"
}
