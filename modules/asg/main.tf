resource "aws_launch_template" "worker_lt" {
  name_prefix   = "${var.name}-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  iam_instance_profile {
    name = var.iam_instance_profile_name
  }
  user_data = base64encode(var.user_data)

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.volume_size
      volume_type = var.volume_type
    }
  }

  network_interfaces {
    security_groups = var.security_group_ids
  }
}

resource "aws_autoscaling_group" "worker_asg" {
  name                      = "${var.name}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  launch_template {
    id      = aws_launch_template.worker_lt.id
    version = "$Latest"
  }
  dynamic "tag" {
    for_each = var.tags
    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }
    
  health_check_type         = "EC2"
  health_check_grace_period = 60

  lifecycle {
    create_before_destroy = true
  }
}
