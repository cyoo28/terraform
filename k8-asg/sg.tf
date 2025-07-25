locals {
  vpc_cidr = data.aws_vpc.ix_vpc.cidr_block
}

resource "aws_security_group" "workerSg" {
  name        = "${local.worker_name}-sg"
  description = "Security group for Kubernetes worker node"
  vpc_id      = local.vpc_id

  tags = merge({
    Name = "${local.worker_name}"
  }, local.tags)
}

resource "aws_security_group_rule" "worker_ingress_ssh_from_bastion" {
  description              = "Allow ssh from bastion"
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workerSg.id
  source_security_group_id = data.aws_security_group.bastionSg.id
}

resource "aws_security_group_rule" "worker_ingress_kubelet_from_vpc" {
  description              = "Allow kubelet api from vpc"
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workerSg.id
  cidr_blocks              = [local.vpc_cidr]
}

resource "aws_security_group_rule" "worker_ingress_nodeport_from_vpc" {
  description              = "Allow nodeport service traffic from vpc"
  type                     = "ingress"
  from_port                = 30000
  to_port                  = 30767
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workerSg.id
  cidr_blocks              = [local.vpc_cidr]
}

resource "aws_security_group_rule" "worker_ingress_weave1_from_vpc" {
  description              = "Allow weavenet traffic from vpc"
  type                     = "ingress"
  from_port                = 6783
  to_port                  = 6784
  protocol                 = "udp"
  security_group_id        = aws_security_group.workerSg.id
  cidr_blocks              = [local.vpc_cidr]
}

resource "aws_security_group_rule" "worker_ingress_weave2_from_vpc" {
  description              = "Allow weavenet traffic from vpc"
  type                     = "ingress"
  from_port                = 6783
  to_port                  = 6784
  protocol                 = "tcp"
  security_group_id        = aws_security_group.workerSg.id
  cidr_blocks              = [local.vpc_cidr]
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