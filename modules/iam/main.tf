resource "aws_iam_role" "controller_role" {
  name = "${var.controller_name}-role"

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

  tags = var.tags
}

resource "aws_iam_role_policy" "controller_policy" {
  name = "${var.controller_name}-policy"
  role = aws_iam_role.controller_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:*",
          "ec2:Describe*",
          "ec2:CreateTags"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "controller_profile" {
  name = "${var.controller_name}-profile"
  role = aws_iam_role.controller_role.name

  tags = var.tags
}

resource "aws_iam_role" "worker_role" {
  name = "${var.worker_name}-role"

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

  tags = var.tags
}

resource "aws_iam_role_policy" "worker_policy" {
  name = "${var.worker_name}-policy"
  role = aws_iam_role.worker_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ec2:Describe*",
          "sts:AssumeRole"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "worker_profile" {
  name = "${var.worker_name}-profile"
  role = aws_iam_role.worker_role.name

  tags = var.tags
}
