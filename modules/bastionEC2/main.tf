resource "aws_instance" "bastionEc2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  root_block_device {
    volume_size = var.volume_size
    volume_type = "gp3"
  }

  tags = merge({
    Name = "${var.name}"
  }, var.tags)
}
