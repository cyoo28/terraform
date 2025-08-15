resource "aws_iam_role" "bastion_admin_role" {
  name = "${local.bastion_name}-admin-role"

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

resource "aws_iam_role_policy" "bastion_admin_policy" {
  name   = "${local.bastion_name}-admin-policy"
  role   = aws_iam_role.bastion_admin_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster"
        ],
        Resource = "arn:aws:eks:us-east-1:026090555438:cluster/test-cluster"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "bastion_admin_profile" {
  name = "${local.bastion_name}-admin-profile"
  role = aws_iam_role.bastion_admin_role.name
  tags = local.tags
}

resource "aws_iam_role" "bastion_dev_role" {
  name = "${local.bastion_name}-dev-role"
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

resource "aws_iam_role_policy" "bastion_dev_policy" {
  name   = "${local.bastion_name}-dev-policy"
  role   = aws_iam_role.bastion_dev_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster"
        ],
        Resource = "arn:aws:eks:us-east-1:026090555438:cluster/test-cluster"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "bastion_dev_profile" {
  name = "${local.bastion_name}-dev-profile"
  role = aws_iam_role.bastion_dev_role.name
  tags = local.tags
}