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
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.bastionSg.id
  cidr_blocks              = [local.local_cidr]
}