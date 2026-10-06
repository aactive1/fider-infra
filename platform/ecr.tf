resource "aws_ecr_repository" "fider" {
  name                 = "fider-app"
  image_tag_mutability = "IMMUTABLE"
  tags = {
    Name      = "fider-app"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
  image_scanning_configuration {
    scan_on_push = true
  }

  #checkov:skip=CKV_AWS_136:Using default AES-256 encryption for this learning project; KMS key management is outside the current scope

}

resource "aws_ecr_lifecycle_policy" "fider" {
  repository = aws_ecr_repository.fider.name
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images older than 7 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 7
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}