locals {
    vpc_id = "vpc-0f6fef9eeeb439491"
    pub_subnet_id = "subnet-020c7a0407b1103ba"
    priv_subnet_id_1 = "subnet-0969efc2e55a650c9"
    priv_subnet_id_2 = "subnet-06cb7f01f6d06ba37"
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
    # bastion related variables
    bastion_name = "k8-bastion"
    bastion_instance_type = "t2.micro"
    bastion_volume_size = 8
    # controller related variables
    controller_name = "k8-controller"
    controller_instance_type = "t2.medium"
    controller_volume_size = 12
    controller_userdata = file("${path.module}/scripts/controller_setup.sh")
    # worker related variables
    worker_name = "k8-worker"
    worker_instance_type = "t2.small"
    worker_volume_size = 8
    worker_userdata = file("${path.module}/scripts/worker_setup.sh")
    iam_instance_profile_name = "genai-webapp"
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

# SECURITY GROUPS
module "sg" {
  source = "./modules/sg"

  vpc_id = data.aws_vpc.ix_vpc.id
  local_cidr = local.local_cidr
  vpc_cidr = data.aws_vpc.ix_vpc.cidr_block
  bastion_name = local.bastion_name
  controller_name = local.controller_name
  worker_name = local.worker_name
  tags = local.tags
}

# IAM PROFILES
module "iam" {
  source = "./modules/iam"

  controller_name = local.controller_name
  worker_name = local.worker_name
  tags = local.tags
}

# BASTION HOST
module "bastion_ec2" {
  source = "./modules/ec2"

  ami_id = local.ami_id
  instance_type = local.bastion_instance_type
  key_name = local.key_name
  subnet_id = local.pub_subnet_id
  volume_size = local.bastion_volume_size
  volume_type = local.volume_type
  security_group_id  = module.sg.bastion_security_group_id
  name = local.bastion_name
  tags = local.tags
}

# CONTROL PLANE EC2
module "controller_ec2" {
  source = "./modules/ec2"

  ami_id = local.ami_id
  instance_type = local.controller_instance_type
  key_name = local.key_name
  subnet_id = local.priv_subnet_id_1
  volume_size = local.controller_volume_size
  volume_type = local.volume_type
  security_group_id  = module.sg.controller_security_group_id
  iam_instance_profile_name = module.iam.controller_instance_profile_name
  user_data = local.controller_userdata
  name = local.controller_name
  tags = local.tags
}

# WORKER EC2 INSTANCES
module "worker_ec2" {
  source = "./modules/ec2"

  ami_id = local.ami_id
  instance_type = local.worker_instance_type
  key_name = local.key_name
  subnet_id = local.priv_subnet_id_2
  volume_size = local.worker_volume_size
  volume_type = local.volume_type
  security_group_id  = module.sg.worker_security_group_id
  iam_instance_profile_name = module.iam.worker_instance_profile_name
  user_data = local.worker_userdata
  name = local.worker_name
  tags = local.tags
}