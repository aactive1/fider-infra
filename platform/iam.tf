resource "aws_iam_role" "github_ecr" {
  name = "fider-github-ecr-push"
  tags = {
    Name      = "fider-github-ecr-push"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "${aws_iam_openid_connect_provider.github.arn}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:aaden04/fider-app:ref:refs/heads/main"
        }
      }
    }
  ]
}
EOF

}

resource "aws_iam_role_policy" "github_ecr_push" {
  name = "fider-ecr-push"
  role = aws_iam_role.github_ecr.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:PutImage",
        "ecr:BatchGetImage"
      ],
      "Resource": "${aws_ecr_repository.fider.arn}"
    }
  ]
}
EOF
}