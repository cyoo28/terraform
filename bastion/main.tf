locals {
    vpc_id = "vpc-03da03e09824cc835"
    pub_subnet_id = "subnet-07e44b3cb81f451e0"
    key_name = "ix-key"
    local_cidr = "98.110.49.120/32"
    tags = {
      Project     = "genai-webapp"
      Environment = "dev"
      Owner       = "charles.yoo"
      ManagedBy   = "Terraform"
    }
    # ec2 related variables
    ami_id = "ami-020cba7c55df1f615"
    volume_type = "gp3"
    bastion_name = "bastion"
    instance_type = "t2.micro"
    volume_size = 12
    userdata = file("${path.module}/scripts/bastion_setup.sh")
}

# Fetch existing subnets by IDs
data "aws_subnet" "public_subnet" {
  id = local.pub_subnet_id
}

data "aws_key_pair" "existing" {
  key_name = local.key_name
}

# Admin Bastion
module "bastion_admin" {
  source = "../modules/ec2"

  ami_id = local.ami_id
  instance_type = local.instance_type
  key_name = local.key_name
  subnet_id = local.pub_subnet_id
  volume_size = local.volume_size
  volume_type = local.volume_type
  security_group_id  = aws_security_group.bastionSg.id
  iam_instance_profile_name = aws_iam_instance_profile.bastion_admin_profile.name
  user_data = local.userdata
  tags = merge(local.tags, {"Name" = "${local.bastion_name}-admin"})
}

# Dev Bastion
module "bastion_dev" {
  source = "../modules/ec2"

  ami_id = local.ami_id
  instance_type = local.instance_type
  key_name = local.key_name
  subnet_id = local.pub_subnet_id
  volume_size = local.volume_size
  volume_type = local.volume_type
  security_group_id  = aws_security_group.bastionSg.id
  iam_instance_profile_name = aws_iam_instance_profile.dev_admin_profile.name
  user_data = local.userdata
  tags = merge(local.tags, {"Name" = "${local.bastion_name}-dev"})
}