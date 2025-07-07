locals {
    vpc_id = "vpc-0f6fef9eeeb439491"
    pub_subnet_id = "subnet-020c7a0407b1103ba"
    priv_subnet_id_1 = "subnet-0969efc2e55a650c9"
    priv_subnet_id_2 = "subnet-06cb7f01f6d06ba37"
    key_name = "ix-key"
    local_cidr = "98.110.49.120/32"
    common_tags = {
      Project     = "genai-webapp"
      Environment = "dev"
      Owner       = "charles.yoo"
      ManagedBy   = "Terraform"
    }
    # bastion related variables
    bastion_name = "k8-bastion"
    bastion_ami_id = "ami-05ffe3c48a9991133"
    bastion_instance_type = "t2.micro"
    bastion_volume_size = 8
    bastion_volume_type = "gp3"
    bastion_tags = merge({
      Component   = "bastion-host"
    }, local.common_tags)
    # controller related variables
    controller_name = "k8-controller"
    controller_ami_id = "ami-05ffe3c48a9991133"
    controller_instance_type = "t2.medium"
    controller_volume_size = 12
    controller_volume_type = "gp3"
    controller_userdata = file("${path.module}/scripts/controller_setup.sh")
    controller_tags = merge({
      Component   = "control-plane"
    }, local.common_tags)
    # worker related variables
    worker_name = "k8-worker"
    worker_ami_id = "ami-05ffe3c48a9991133"
    worker_instance_type = "t2.small"
    worker_volume_size = 8
    worker_volume_type = "gp3"
    worker_userdata = file("${path.module}/scripts/worker_setup.sh")
    worker_tags = merge({
      Component   = "worker-node"
    }, local.common_tags)
    iam_instance_profile_name = "genai-webapp"
}

data "aws_vpc" "vpc" {
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

  vpc_id = data.aws_vpc.vpc.id
  local_cidr = local.local_cidr
  vpc_cidr = data.aws_vpc.selected.cidr_block
  bastion_name = local.bastion_name
  bastion_tags = local.bastion_tags
  controller_name = local.controller_name
  controller_tags = local.controller_tags
  worker_name = local.worker_name
  worker_tags = local.worker_tags
}

# IAM PROFILES
module "iam" {
  source = "./modules/iam"

  controller_name = local.controller_name
  worker_name = local.worker_name
  tags = local.common_tags
}

# BASTION HOST
module "bastionEC2" {
  source = "./modules/bastionEC2"

  ami_id = local.bastion_ami_id
  instance_type = local.bastion_instance_type
  key_name = local.key_name
  subnet_id = local.pub_subnet_id
  volume_size = local.bastion_volume_size
  volume_type = local.bastion_volume_type
  security_group_id  = module.sg.bastion_security_group_id
  name = local.bastion_name
  tags = local.bastion_tags
}

# CONTROL PLANE EC2
module "controllerEC2" {
  source = "./modules/controllerEC2"

  ami_id = local.controller_ami_id
  instance_type = local.controller_instance_type
  key_name = local.key_name
  subnet_id = local.priv_subnet_id_1
  volume_size = local.controller_volume_size
  volume_type = local.controller_volume_type
  security_group_id  = module.sg.controller_security_group_id
  iam_instance_profile_name = module.iam.controller_instance_profile_name
  user_data = local.controller_userdata
  name = local.controller_name
  tags = local.controller_tags
}

# WORKER EC2 INSTANCES (could be count or for_each)
module "workerEC2" {
  source = "./modules/workerEC2"

  ami_id = local.worker_ami_id
  instance_type = local.worker_instance_type
  key_name = local.key_name
  subnet_id = local.priv_subnet_id_2
  volume_size = local.worker_volume_size
  volume_type = local.worker_volume_type
  security_group_id  = module.sg.worker_security_group_id
  iam_instance_profile_name = module.iam.worker_instance_profile_name
  user_data = local.worker_userdata
  name = local.worker_name
  tags = local.worker_tags
}