resource "aws_instance" "ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  associate_public_ip_address = var.assign_public_ip != null ? var.assign_public_ip : null
  iam_instance_profile   = var.iam_instance_profile_name != "" ? var.iam_instance_profile_name : null
  user_data              = var.user_data != "" ? var.user_data : null

  root_block_device {
    volume_size = var.volume_size
    volume_type = var.volume_type
  }

  tags = merge({
    Name = "${var.name}"
  }, var.tags)
}
