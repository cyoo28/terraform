output "controller_instance_profile_name" {
  value = aws_iam_instance_profile.controller.name
}

output "worker_instance_profile_name" {
  value = aws_iam_instance_profile.worker.name
}

output "controller_role_arn" {
  value = aws_iam_role.controller.arn
}

output "worker_role_arn" {
  value = aws_iam_role.worker.arn
}