locals {
  #vpc_id = data.aws_vpc.ix_vpc.id
  vpc_cidr = data.aws_vpc.ix_vpc.cidr_block
}

resource "aws_security_group" "bastionSg" {
  name        = "${local.bastion_name}-sg"
  description = "Security group for Bastion host"
  vpc_id      = local.vpc_id

  tags = merge({
    Name = "sg-${local.bastion_name}"
  }, local.tags)
}

resource "aws_security_group_rule" "bastion_ingress_ssh_from_local" {
  description              = "Allow SSH from local machine"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastionSg.id
  cidr_blocks              = [local.local_cidr]
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
  name        = "${local.controller_name}-sg"
  description = "Security group for Kubernetes control plane node"
  vpc_id      = local.vpc_id

  tags = merge({
    Name = "sg-${local.controller_name}"
  }, local.tags)
}

resource "aws_security_group_rule" "controller_ingress_ssh_from_bastion" {
  description              = "Allow ssh from bastion"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  source_security_group_id = aws_security_group.bastionSg.id
}

resource "aws_security_group_rule" "controller_ingress_etcd_from_vpc" {
  description              = "Allow etdc server traffic from vpc"
  type                     = "ingress"
  from_port                = 2379
  to_port                  = 2380
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  cidr_blocks              = [local.vpc_cidr]
}

resource "aws_security_group_rule" "controller_ingress_kubernetes_from_vpc" {
  description              = "Allow kubernetes server traffic from vpc"
  type                     = "ingress"
  from_port                = 6443
  to_port                  = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  cidr_blocks              = [local.vpc_cidr]
}

resource "aws_security_group_rule" "controller_ingress_kubelet_from_vpc" {
  description              = "Allow kubelet traffic from vpc"
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10259
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  cidr_blocks              = [local.vpc_cidr]
}

resource "aws_security_group_rule" "controller_ingress_weave1_from_vpc" {
  description              = "Allow weavenet traffic from vpc"
  type                     = "ingress"
  from_port                = 6783
  to_port                  = 6784
  protocol                 = "udp"
  security_group_id        = aws_security_group.controllerSg.id
  cidr_blocks              = [local.vpc_cidr]
}

resource "aws_security_group_rule" "controller_ingress_weave2_from_vpc" {
  description              = "Allow weavenet traffic from vpc"
  type                     = "ingress"
  from_port                = 6783
  to_port                  = 6784
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controllerSg.id
  cidr_blocks              = [local.vpc_cidr]
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