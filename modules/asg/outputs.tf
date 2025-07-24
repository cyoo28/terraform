output "asg_name" {
  value = aws_autoscaling_group.worker_asg.name
}

output "launch_template_id" {
  value = aws_launch_template.worker_lt.id
}