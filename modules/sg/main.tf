resource "aws_security_group" "bastionSg" {
  name        = "${var.bastion_name}-sg"
  description = "Security group for Bastion host"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "sg-${var.bastion_name}"
  }, var.bastion_tags)
}

resource "aws_security_group_rule" "bastion_ingress_ssh_from_local" {
  description              = "Allow SSH from local machine"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastionSg.id
  cidr_blocks              = [var.local_cidr]
  
}

resource "aws_security_group_rule" "bastion_egress_ssh_from_ec2connect" {
  description              = "Allow SSH from EC2 Connect"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastionSg.id
  cidr_blocks              = ["18.206.107.24/29"]
  
}

resource "aws_security_group_rule" "bastion_egress_all_to_all" {
  description              = "Allow https outbound"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.bastionSg.id
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group" "controllerSg" {
  name        = "${var.controller_name}-sg"
  description = "Security group for Kubernetes control plane node"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "sg-${var.controller_name}"
  }, var.controller_tags)
}

resource "aws_security_group_rule" "controller_ingress_icmp_from_vpc" {
  description              = "Allow ICMP from VPC CIDR"
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.controllerSg.id
  cidr_blocks              = [var.vpc_cidr]
}

resource "aws_security_group_rule" "controller_ingress_ssh_from_bastion" {
  description              = "Allow ssh from bastion sg"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  source_security_group_id = aws_security_group.bastionSg.id
}

resource "aws_security_group_rule" "controller_ingress_tcp_from_worker" {
  description              = "Allow tcp from worker sg"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  source_security_group_id = aws_security_group.workerSg.id
}

resource "aws_security_group_rule" "controller_ingress_tcp_from_controller" {
  description              = "Allow tcp from controller sg"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  source_security_group_id = aws_security_group.controllerSg.id
}

resource "aws_security_group_rule" "controller_egress_all_to_all" {
  description              = "Allow all outbound"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.controllerSg.id
  cidr_blocks              = ["0.0.0.0/0"]
}

resource "aws_security_group" "workerSg" {
  name        = "${var.worker_name}-sg"
  description = "Security group for Kubernetes worker node"
  vpc_id      = var.vpc_id

  tags = merge({
    Name = "${var.worker_name}"
  }, var.worker_tags)
}

resource "aws_security_group_rule" "worker_ingress_icmp_from_vpc" {
  description              = "Allow ICMP from VPC CIDR"
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "icmp"
  security_group_id        = aws_security_group.workerSg.id
  cidr_blocks              = [var.vpc_cidr]
}

resource "aws_security_group_rule" "worker_ingress_ssh_from_bastion" {
  description              = "Allow ssh from bastion sg"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workerSg.id
  source_security_group_id = aws_security_group.bastionSg.id
}

resource "aws_security_group_rule" "worker_ingress_tcp_from_worker" {
  description              = "Allow tcp from worker sg"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workerSg.id
  source_security_group_id = aws_security_group.workerSg.id
}

resource "aws_security_group_rule" "worker_ingress_tcp_from_controller" {
  description              = "Allow tcp from controller sg"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workerSg.id
  source_security_group_id = aws_security_group.controllerSg.id
}

resource "aws_security_group_rule" "worker_egress_all_to_all" {
  description              = "Allow all outbound"
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.workerSg.id
  cidr_blocks              = ["0.0.0.0/0"]
}