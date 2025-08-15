locals {
  #vpc_id = data.aws_vpc.ix_vpc.id
  vpc_cidr = data.aws_vpc.ix_vpc.cidr_block
}

resource "aws_security_group" "bastionSg" {
  name        = "${local.bastion_name}-sg"
  description = "Security group for bastion host"
  vpc_id      = local.vpc_id

  tags = merge({
    Name = "sg-${local.bastion_name}"
  }, local.tags)
}

resource "aws_security_group_rule" "bastion_ingress_ssh_from_local" {
  description              = "Allow ssh from local machine"
  type                     = "egress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastionSg.id
  cidr_blocks              = [locals.local_cidr]
}