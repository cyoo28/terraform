resource "aws_security_group" "workerSg" {
  name        = "${var.name}-worker-sg"
  description = "Security group for Kubernetes worker node"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow SSH from Bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  ingress {
    description     = "Kubelet API (10250) from Controller"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [var.controller_sg_id]
  }

  ingress {
    description     = "Weave Net TCP (6783)"
    from_port       = 6783
    to_port         = 6783
    protocol        = "tcp"
    security_groups = [aws_security_group.workerSg.id]
  }

  ingress {
    description     = "Weave Net UDP (6783)"
    from_port       = 6783
    to_port         = 6783
    protocol        = "udp"
    security_groups = [aws_security_group.workerSg.id]
  }

  ingress {
    description     = "Weave Net TCP Fast Datapath (6784)"
    from_port       = 6784
    to_port         = 6784
    protocol        = "tcp"
    security_groups = [aws_security_group.workerSg.id]
  }

  ingress {
    description = "ICMP (Ping/Diagnostics) from VPC CIDR"
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
    Name = "${var.name}-worker-sg"
  }, var.tags)
}

resource "aws_instance" "worker" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.workerSg.id]
  key_name               = var.key_name
  iam_instance_profile   = var.iam_instance_profile_name

  user_data              = var.user_data

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = merge({
    Name = "${var.name}-worker"
  }, var.tags)
}
