locals {
    vpc_id = "vpc-03da03e09824cc835"
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
    ec2_tags = merge(local.tags, {"Name" = "k8-worker"}, {"kubernetes.io/cluster/${local.cluster_id}" = "owned"})
    # asg related variables
    asg_tags = merge(local.ec2_tags, {"k8s.io/cluster-autoscaler/${local.cluster_id}" = "owned"}, {"k8s.io/cluster-autoscaler/enabled" = "true"})
    # worker related variables
    worker_name = "k8-worker"
    worker_instance_type = "t3.small"
    worker_volume_size = 8
    worker_userdata = file("${path.module}/scripts/worker_setup.sh")
    iam_instance_profile_name = "genai-webapp"
    bastion_sg = "bastion-sg"
}

data "aws_vpc" "ix_vpc" {
  id = local.vpc_id
}

data "aws_key_pair" "existing" {
  key_name = local.key_name
}

data "aws_security_group" "bastionSg" {
  filter {
    name   = "group-name"
    values = [local.bastion_sg]
  }
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
} 

/*
# WORKER EC2 INSTANCES
module "worker_ec2" {
  source = "../modules/ec2"

  ami_id = local.ami_id
  instance_type = local.worker_instance_type
  key_name = local.key_name
  subnet_id = local.priv_subnet_id_1
  volume_size = local.worker_volume_size
  volume_type = local.volume_type
  security_group_ids  = [aws_security_group.workerSg.id]
  iam_instance_profile_name = aws_iam_instance_profile.worker_profile.name
  tags = local.ec2_tags
}*/

module "worker_asg" {
  source                 = "../modules/asg"

  ami_id                 = local.ami_id
  instance_type          = local.worker_instance_type
  key_name               = local.key_name
  iam_instance_profile_name = aws_iam_instance_profile.worker_profile.name
  user_data              = local.worker_userdata
  volume_size            = local.worker_volume_size
  volume_type            = local.volume_type
  security_group_ids     = [aws_security_group.workerSg.id]
  subnet_ids             = [local.priv_subnet_id_1, local.priv_subnet_id_2]
  desired_capacity       = 1
  min_size               = 1
  max_size               = 3
  tags                   = local.asg_tags
  name                   = local.worker_name
}

resource "aws_autoscaling_schedule" "scale_down_evening" {
  scheduled_action_name  = "${local.worker_name}-scale-down"
  autoscaling_group_name = module.worker_asg.asg_name
  desired_capacity       = 0
  min_size               = 0
  max_size               = 0
  recurrence             = "0 22 * * *" # 6 PM EST
}

resource "aws_autoscaling_schedule" "scale_up_morning" {
  scheduled_action_name  = "${local.worker_name}-scale-up"
  autoscaling_group_name = module.worker_asg.asg_name
  desired_capacity       = 1
  min_size               = 1
  max_size               = 3
  recurrence             = "0 13 * * *" # 9 AM EST
}

