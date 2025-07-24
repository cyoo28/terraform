locals {
    webapp_name = "genai-webapp"
    worker_sg_name = "k8-worker-role"
    tags = {
      Project     = "genai-webapp"
      Environment = "dev"
      Owner       = "charles.yoo"
      ManagedBy   = "Terraform"
    }
}

data "aws_iam_role" "k8_worker" {
  name = local.worker_sg_name
}

resource "aws_iam_role" "webapp_role" {
  name = "${local.webapp_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = data.aws_iam_role.k8_worker.arn
      },
      Action = "sts:AssumeRole"
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "webapp_policy" {
  name = "${local.webapp_name}-policy"
  role = aws_iam_role.webapp_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
            "ec2:DescribeInstances",
            "ec2:DescribeRegions",
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:GetRepositoryPolicy",
            "ecr:DescribeRepositories",
            "ecr:ListImages",
            "ecr:BatchGetImage",
            "ses:SendEmail",
            "secretsmanager:GetSecretValue",
            "kms:Decrypt",
            "ssm:GetParameter"
        ],
        Resource = "*"
      }
    ]
  })
}