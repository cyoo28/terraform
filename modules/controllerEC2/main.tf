resource "aws_security_group" "controllerSg" {
  name        = "sg-${var.name}"
  description = "Security group for Kubernetes control plane node"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from Bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  ingress {
    description = "Allow Kubernetes API server access (6443)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    security_groups = concat(var.worker_node_sg_id, [var.bastion_sg_id])
  }

  ingress {
    description = "Allow etcd server client API (2379-2380)"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    security_groups = [aws_security_group.controllerSg.id]
  }

  ingress {
    description = "Allow ICMP from VPC CIDR"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "sg-${var.name}"
  }, var.tags)
}

resource "aws_instance" "controllerEc2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.controllerSg.id]
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile_name

  user_data              = var.user_data

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = merge({
    Name = "${var.name}"
  }, var.tags)
}
