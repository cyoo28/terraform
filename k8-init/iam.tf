resource "aws_iam_role" "controller_role" {
  name = "${local.controller_name}-role"

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

resource "aws_iam_role_policy" "controller_policy" {
  name = "${local.controller_name}-policy"
  role = aws_iam_role.controller_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "elasticloadbalancing:*",
          "ec2:Describe*",
          "ec2:CreateTags",
          "ec2:CreateSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateVolume",
          "ec2:ModifyVolume",
          "ec2:AttachVolume",
          "ec2:DeleteVolume",
          "ec2:DetachVolume",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:ModifyInstanceAttribute",
          "ec2:AttachNetworkInterface",
          "iam:CreateServiceLinkedRole",
          "kms:DescribeKey"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "controller_profile" {
  name = "${local.controller_name}-profile"
  role = aws_iam_role.controller_role.name

  tags = local.tags
}

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
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "ec2:Describe*",
          "ec2:AttachNetworkInterface",
          "ec2:DetachNetworkInterface",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "sts:AssumeRole"
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
