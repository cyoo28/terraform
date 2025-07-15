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
    ec2_tags = merge(local.tags, {"kubernetes.io/cluster/kubernetes" = "owned"})
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
  name = local.bastion_name
  tags = local.tags
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
  name = local.controller_name
  tags = local.ec2_tags
}

# WORKER EC2 INSTANCES
module "worker1_ec2" {
  source = "../modules/ec2"

  ami_id = local.ami_id
  instance_type = local.worker_instance_type
  key_name = local.key_name
  subnet_id = local.priv_subnet_id_1
  volume_size = local.worker_volume_size
  volume_type = local.volume_type
  security_group_id  = aws_security_group.workerSg.id
  iam_instance_profile_name = aws_iam_instance_profile.worker_profile.name
  user_data = local.worker_userdata
  name = "${local.worker_name}-1"
  tags = local.ec2_tags
}

module "worker2_ec2" {
  source = "../modules/ec2"

  ami_id = local.ami_id
  instance_type = local.worker_instance_type
  key_name = local.key_name
  subnet_id = local.priv_subnet_id_2
  volume_size = local.worker_volume_size
  volume_type = local.volume_type
  security_group_id  = aws_security_group.workerSg.id
  iam_instance_profile_name = aws_iam_instance_profile.worker_profile.name
  user_data = local.worker_userdata
  name = "${local.worker_name}-2"
  tags = local.ec2_tags
}