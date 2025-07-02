resource "aws_security_group" "bastionSg" {
  name        = "sg-${var.name}"
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
    security_groups = concat(var.controller_sg_id, [var.worker_node_sg_id])
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

resource "aws_instance" "bastionEc2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.bastionSg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = merge({
    Name = "${var.name}"
  }, var.tags)
}
