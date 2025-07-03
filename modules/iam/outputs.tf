output "controller_instance_profile_name" {
  value = aws_iam_instance_profile.controller_profile.name
}

output "worker_instance_profile_name" {
  value = aws_iam_instance_profile.worker_profile.name
}

output "controller_role_arn" {
  value = aws_iam_role.controller_role.arn
}

output "worker_role_arn" {
  value = aws_iam_role.worker_role.arn
}