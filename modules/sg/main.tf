resource "aws_security_group" "bastionSg" {
  name        = "${var.bastion_name}-sg"
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

resource "aws_security_group_rule" "bastion_egress_ssh_to_controller" {
  description              = "Allow SSH to control plane from Bastion"
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastionSg.id
  source_security_group_id = aws_security_group.controllerSg.id
  
}

resource "aws_security_group_rule" "bastion_egress_ssh_to_worker" {
  description              = "Allow SSH to workers from Bastion"
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastionSg.id
  source_security_group_id = aws_security_group.workerSg.id
}

resource "aws_security_group" "controllerSg" {
  name        = "${var.controller_name}-sg"
  description = "Security group for Kubernetes control plane node"
  vpc_id      = var.vpc_id

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

resource "aws_security_group_rule" "controller_ingress_ssh_from_bastion" {
  description              = "Allow SSH from Bastion to Controller"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  source_security_group_id = aws_security_group.bastionSg.id
}

resource "aws_security_group_rule" "controller_ingress_k8s_api" {
  description              = "Allow K8s API from Bastion"
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  source_security_group_id = aws_security_group.bastionSg.id
}

resource "aws_security_group_rule" "controller_ingress_k8s_api_worker" {
  description              = "Allow K8s API from Worker Nodes"
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  source_security_group_id = aws_security_group.workerSg.id
}

resource "aws_security_group_rule" "controller_ingress_etcd" {
  description              = "Allow etcd traffic within Controllers"
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2380
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  source_security_group_id = aws_security_group.controllerSg.id
}

resource "aws_security_group" "workerSg" {
  name        = "${var.worker_name}-sg"
  description = "Security group for Kubernetes worker node"
  vpc_id      = var.vpc_id

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

resource "aws_security_group_rule" "worker_ingress_ssh_from_bastion" {
  description              = "Allow SSH from Bastion to Workers"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workerSg.id
  source_security_group_id = aws_security_group.bastionSg.id
}

resource "aws_security_group_rule" "worker_ingress_kubelet" {
  description              = "Allow Kubelet API from Controller"
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workerSg.id
  source_security_group_id = aws_security_group.controllerSg.id
}

resource "aws_security_group_rule" "worker_ingress_pod_network" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.workerSg.id
  source_security_group_id = aws_security_group.workerSg.id
  description              = "Allow all traffic from Worker SG (pod network)"
}

resource "aws_security_group_rule" "worker_ingress_ip_in_ip" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "4"  # IP-in-IP protocol number
  security_group_id        = aws_security_group.workerSg.id
  source_security_group_id = aws_security_group.workerSg.id
  description              = "Allow IP-in-IP encapsulation between Worker nodes"
}