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
    ec2_tags = merge(local.tags, {"kubernetes.io/cluster/${local.cluster_id}" = "owned"})
    # worker related variables
    worker_name = "k8-worker"
    worker_instance_type = "t3.small"
    worker_volume_size = 8
    worker_userdata = file("${path.module}/scripts/worker_setup.sh")
    iam_instance_profile_name = "genai-webapp"
}

data "aws_vpc" "ix_vpc" {
  id = local.vpc_id
}

data "aws_key_pair" "existing" {
  key_name = local.key_name
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