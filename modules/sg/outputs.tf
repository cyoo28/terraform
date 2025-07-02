output "bastion_security_group_id" {
  value = aws_security_group.bastionSg.id
}

output "controller_security_group_id" {
  value = aws_security_group.controllerSg.id
}

output "worker_security_group_id" {
  value = aws_security_group.workerSg.id
}