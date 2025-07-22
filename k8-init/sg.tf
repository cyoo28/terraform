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

resource "aws_security_group_rule" "bastion_ingress_ssh_from_ec2connect" {
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
  name        = "${local.controller_name}-sg"
  description = "Security group for Kubernetes control plane node"
  vpc_id      = local.vpc_id

  tags = merge({
    Name = "sg-${local.controller_name}"
  }, local.tags)
}

resource "aws_security_group_rule" "controller_ingress_all_from_vpc" {
  description              = "Allow all traffic from vpc"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
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