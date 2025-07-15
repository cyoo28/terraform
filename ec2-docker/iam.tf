resource "aws_iam_role" "docker_role" {
  name = "${local.name}-role"

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

resource "aws_iam_role_policy" "ecr_policy" {
  name = "${local.name}-policy"
  role = aws_iam_role.docker_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "docker_profile" {
  name = "${local.name}-profile"
  role = aws_iam_role.docker_role.name
  tags = local.tags
}