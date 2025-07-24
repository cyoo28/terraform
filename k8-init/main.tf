locals {
    vpc_id = "vpc-03da03e09824cc835"
    pub_subnet_id = "subnet-07e44b3cb81f451e0"
    priv_subnet_id_1 = "subnet-03d93b0775588b7c1"
    priv_subnet_id_2 = "subnet-0143a61d78c69fdaf"
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
    cluster_id="kubernetes"
    ec2_tags = merge(local.tags, {"kubernetes.io/cluster/${local.cluster_id}" = "owned"})
    # bastion related variables
    bastion_name = "bastion"
    bastion_tags = merge(local.tags, {"Name" = "${local.bastion_name}"})
    bastion_instance_type = "t2.micro"
    bastion_volume_size = 8
    # controller related variables
    controller_name = "k8-controller"
    controller_tags = merge(local.ec2_tags, {"Name" = "${local.controller_name}"})
    controller_instance_type = "t3.small"
    controller_volume_size = 12
    controller_userdata = file("${path.module}/scripts/controller_setup.sh")
}

data "aws_vpc" "ix_vpc" {
  id = local.vpc_id
}

# Fetch existing subnets by IDs
data "aws_subnet" "public_subnet" {
  id = local.pub_subnet_id
}

data "aws_subnet" "private_subnet" {
  id = local.priv_subnet_id_1
}

data "aws_key_pair" "existing" {
  key_name = local.key_name
}

# BASTION HOST
module "bastion_ec2" {
  source = "../modules/ec2"

  ami_id = local.ami_id
  instance_type = local.bastion_instance_type
  key_name = local.key_name
  subnet_id = local.pub_subnet_id
  volume_size = local.bastion_volume_size
  volume_type = local.volume_type
  security_group_id  = aws_security_group.bastionSg.id
  assign_public_ip = true
  tags = local.bastion_tags
}

# CONTROL PLANE EC2
module "controller_ec2" {
  source = "../modules/ec2"

  ami_id = local.ami_id
  instance_type = local.controller_instance_type
  key_name = local.key_name
  subnet_id = local.priv_subnet_id_1
  volume_size = local.controller_volume_size
  volume_type = local.volume_type
  security_group_id  = aws_security_group.controllerSg.id
  iam_instance_profile_name = aws_iam_instance_profile.controller_profile.name
  user_data = local.controller_userdata
  tags = local.controller_tags
}