output "instance_id" {
  value = aws_instance.controllerEc2.id
}

output "private_ip" {
  value = aws_instance.controllerEc2.private_ip
}