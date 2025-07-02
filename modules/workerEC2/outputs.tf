output "instance_id" {
  value = aws_instance.workerEc2.id
}

output "private_ip" {
  value = aws_instance.workerEc2.private_ip
}

