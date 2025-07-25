resource "aws_iam_role" "worker_role" {
  name = "${local.worker_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "worker_policy" {
  name = "${local.worker_name}-policy"
  role = aws_iam_role.worker_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          // EC2 Describe
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          // ECR Core
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          // Assume role
          "sts:AssumeRole",
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "${local.worker_name}-profile"
  role = aws_iam_role.worker_role.name

  tags = local.tags
}