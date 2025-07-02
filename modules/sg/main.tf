resource "aws_security_group" "bastionSg" {
  name        = "sg-${var.bastion_name}"
  description = "Security group for Bastion host"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from local machine"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.local_cidr]
  }

  egress {
    description = "Allow SSH to control plane/worker node SGs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = concat(aws_security_group.controllerSg.id, [aws_security_group.workerSg.id])
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "sg-${var.bastion_name}"
  }, var.bastion_tags)
}

resource "aws_security_group" "controllerSg" {
  name        = "sg-${var.controller_name}"
  description = "Security group for Kubernetes control plane node"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow SSH from Bastion host"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastionSg.id]
  }

  ingress {
    description = "Allow Kubernetes API server access (6443)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    security_groups = concat(aws_security_group.workerSg.id, [aws_security_group.bastionSg.id])
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
    Name = "sg-${var.controller_name}"
  }, var.controller_tags)
}

resource "aws_security_group" "workerSg" {
  name        = "${var.worker_name}"
  description = "Security group for Kubernetes worker node"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow SSH from Bastion host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastionSg.id]
  }

  ingress {
    description     = "Kubelet API (10250) from Controller"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.controllerSg.id]
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
    Name = "${var.worker_name}"
  }, var.worker_tags)
}