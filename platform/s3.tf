
resource "aws_s3_bucket" "fider_eks_uploads_dev" {
  bucket = "fider-eks-uploads-dev-aa"

  tags = {
    Name      = "fider-eks-uploads-dev-aa"
    Project   = "fider-eks"
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_bucket_public_access_block" "fider_public_access_block" {
  bucket = aws_s3_bucket.fider_eks_uploads_dev.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "fider_encryption" {
  bucket = aws_s3_bucket.fider_eks_uploads_dev.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "fider_lifecycle" {
  bucket = aws_s3_bucket.fider_eks_uploads_dev.id

  rule {
    id     = "abort-incomplete-uploads"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
