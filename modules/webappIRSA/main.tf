resource "aws_iam_role" "webapp_role" {
  name = "${var.webapp_name}-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${var.oidc_provider}"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        StringEquals = {
          "${var.oidc_provider}:sub" = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
        }
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "webapp_policy" {
  name = "${var.webapp_name}-irsa-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = var.secret_arns
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ],
        Resource = var.parameter_arns
      }
    ]
  })
}