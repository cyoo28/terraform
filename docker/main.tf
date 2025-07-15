locals {
  security_group_id = "sg-0f066f4b0faf24a37"
  subnet_id = "subnet-03d93b0775588b7c1"
  key_name = "ix-key"
  tags = {
    Project     = "docker"
    Environment = "dev"
    Owner       = "charles.yoo"
    ManagedBy   = "Terraform"
  }
  # ec2 related variables
  ami_id = "ami-0150ccaf51ab55a51"
  volume_type = "gp3"
  name = "docker"
  instance_type = "t2.small"
  volume_size = 100
  userdata = file("${path.module}/docker_setup.sh")
}

module "docker_ec2" {
  source = "../modules/ec2"

  ami_id = local.ami_id
  instance_type = local.instance_type
  key_name = local.key_name
  subnet_id = local.subnet_id
  volume_size = local.volume_size
  volume_type = local.volume_type
  security_group_id  = local.security_group_id
  iam_instance_profile_name = aws_iam_instance_profile.docker_profile.name
  user_data = local.userdata
  name = "${local.name}"
  tags = local.tags
}
